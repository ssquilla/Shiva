
using WebKit;
using GLib;

namespace session {

    public class PersistentWebView : WebKit.WebView  {
        
        public string defaultURL { get; set;}

        public string networkName { get ; set;}

        public Secret.Schema secretSchema {get; set;}

        internal TlsCertificate? tls { get; protected set; default = null; }

        construct{

        }


        public PersistentWebView(string defaultURL, string networkName){
            Object();
            this.defaultURL = defaultURL;
            this.networkName = networkName;
            
            setupWebView();
            //permissionRequest = new NotificationPermissionRequest();
            //new WebKit.NotificationPermissionRequest().allow();
            //pageAutomatizer = new PageAutomatizer(this);

        }

        public override bool show_notification (WebKit.Notification webkit_notification) {
            // Don't show notifications for the visible tab

            var notification = new GLib.Notification (webkit_notification.title);
            notification.set_body (webkit_notification.body);
            // Use a per-host ID to avoid collisions, but neglect the tag
            //string hostname = new Soup.URI (uri).host;
            Application.get_default ().send_notification ("web-%s".printf (webkit_notification.title), notification);
            sendNotify(webkit_notification.body);
            return true;
        }        

        public void sendNotify(string content){
            string summary = "Shiva - notification";
            // = Gtk.Stock.DIALOG_INFO
            string icon = "dialog-information";
            try {
                Notify.Notification notification = new Notify.Notification (summary, content, icon);
                notification.show ();
            } catch (Error e) {
                error ("Error: %s", e.message);
            }
        }

        public void setupWebView(){
            load_uri(defaultURL);
            // connect signals
        }
        
        public void reloadURL(){
            load_uri(defaultURL);
        }
    }
}
