import {
  registerHelpers,
  createHelperContext
} from "discourse-common/lib/helpers";
import RawHandlebars from "discourse-common/lib/raw-handlebars";
import { registerRawHelpers } from "discourse-common/lib/raw-handlebars-helpers";
import Handlebars from "handlebars";

export function autoLoadModules(container, registry) {
  Object.keys(requirejs.entries).forEach(entry => {
    if (/\/helpers\//.test(entry) && !/-test/.test(entry)) {
      requirejs(entry, null, null, true);
    }
    if (/\/widgets\//.test(entry) && !/-test/.test(entry)) {
      requirejs(entry, null, null, true);
    }
  });
  let siteSettings = container.lookup("site-settings:main");
  let themeSettings = container.lookup("service:theme-settings");
  createHelperContext({ siteSettings, themeSettings });
  registerHelpers(registry);
  registerRawHelpers(RawHandlebars, Handlebars);
}

export default {
  name: "auto-load-modules",
  initialize: autoLoadModules
};
