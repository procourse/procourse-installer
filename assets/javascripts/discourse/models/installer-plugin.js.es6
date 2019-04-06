import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
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
