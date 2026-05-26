import { createApp } from "vue";
import router from "./router";
import ui from "@nuxt/ui/vue-plugin";
import "./style.css";
import App from "./App.vue";

const app = createApp(App);
app.use(ui);
app.use(router);
app.mount("#app");
