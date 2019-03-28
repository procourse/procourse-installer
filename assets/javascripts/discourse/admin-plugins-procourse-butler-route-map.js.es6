export default {
  resource: "admin.adminPlugins",
  path: "/plugins",
  map() {
    this.route("procourse-butler", function(){
      this.route('index', {path: '/'});
    })
  }
};
