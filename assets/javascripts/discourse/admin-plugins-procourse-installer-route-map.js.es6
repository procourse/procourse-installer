export default {
  resource: "admin.adminPlugins",
  path: "/plugins",
  map() {
    this.route("procourse-installer", function(){
      this.route('index', {path: '/'});
    })
  }
};
