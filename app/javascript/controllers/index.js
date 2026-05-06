import { application } from "controllers/application"
import DocsNavController from "controllers/docs_nav_controller"
import HelloController from "controllers/hello_controller"
import ToastController from "controllers/toast_controller"

application.register("docs-nav", DocsNavController)
application.register("hello", HelloController)
application.register("toast", ToastController)
