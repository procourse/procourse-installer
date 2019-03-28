import { ajax } from 'discourse/lib/ajax';

export default {
  findAll() {
  },

  findById() {
  },
  install(path){
    return ajax(`/butler-store/install`, {
      data: JSON.stringify({"plugin_path": path}),
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json'
    });
  }
};
