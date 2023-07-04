
using WebKit;
using GLib;

namespace session {

    public class PersistentWebView : WebKit.WebView  {
        
        public string defaultURL { get; set;}

        public string networkName { get ; set;}

        public Secret.Schema secretSchema {get; set;}

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
        
        public void setupWebView(){
            load_uri(defaultURL);
            // connect signals
        }
        
        public void reloadURL(){
            load_uri(defaultURL);
        }
    }
}
