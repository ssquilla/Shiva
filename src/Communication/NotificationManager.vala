
using WebKit;
using service;

namespace communication {

    class NotificationManager : NotificationPermissionRequest {

        construct {

        }

        private Array<WebView> webViews;

        private Shiva shiva;

        public NotificationManager(Shiva shiva, Array<WebView> webViews){
            this.webViews = webViews;
            this.shiva = shiva;
            activateNotifications();
            //allow();
        }

        private void activateNotifications(){
            foreach(WebView webView in webViews){
                webView.permission_request.connect(permissionManaging);
                webView.show_notification.connect(manageNotification);
            }
        } 

        public bool manageNotification (WebKit.Notification webkit_notification) {
            shiva.openWindow();
            var notification = new GLib.Notification (webkit_notification.title);
            notification.set_body (webkit_notification.body);
            Application.get_default ().send_notification ("web", notification);
            return true;
        }

        public bool permissionManaging (WebKit.PermissionRequest permission) {
            if (permission is WebKit.GeolocationPermissionRequest) {
                //string hostname = new Soup.URI (uri).host;
                //message.label = _("%s wants to know your location.").printf (hostname);
            } else if (permission is WebKit.NotificationPermissionRequest) {
                permission.allow ();
                stdout.printf("WOOOOOOOOOW\n");
                return true;
            } else {
                stdout.printf("aaaaaa\n");
                //message.label = permission.get_type ().name ();
            }

            return true;
        }

    }
}