import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
    return ajax(`/procourse-installer/installed`);
  },

  findById() {
  },
  install(plugin_url){
    return ajax(`/procourse-installer/install`, {
      data: JSON.stringify({"plugin_url": plugin_url}),
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json'
    });
  }
};
