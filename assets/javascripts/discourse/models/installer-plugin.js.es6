import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
    return ajax(`/procourse-installer/installed`);
  },

  findById() {
  },
  getState() {
    return ajax(`/procourse-installer/install`);
  },
  install(plugin_url){
    return ajax(`/procourse-installer/install`, {
      data: JSON.stringify({"plugin_url": plugin_url}),
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json'
    });
  },
  uninstall(plugin_name){
    return ajax(`/procourse-installer/uninstall/${plugin_name}`, {
      type: 'DELETE',
      dataType: 'json',
      contentType: 'application/json'
    });
  }
};
