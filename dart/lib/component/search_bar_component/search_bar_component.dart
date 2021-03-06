part of security_monkey;

@Component(
    selector: 'search-bar',
    templateUrl: 'packages/security_monkey/component/search_bar_component/search_bar_component.html',
    publishAs: 'cmp',
    useShadowDom: false)
class SearchBarComponent {

    String searchconfig = "";
    String active_filter_value = "null";
    String result_type_binded = "items";
    Router router;
    RouteProvider routeProvider;

    Map<String, String> filter_params = {
        'regions': '',
        'technologies': '',
        'accounts': '',
        'names': '',
        'active': null,
        'searchconfig': null,
        'page': '1',
        'count': '25'
    };

    SearchBarComponent(this.router, this.routeProvider) {
        context['getAPIHost'] = getAPIHost;
        context['getFilterString'] = getFilterString;
        context['pushFilterRoutes'] = pushFilterRoutes;
        this.result_type_binded = this.routeProvider.route.parent.name;
        if (routeProvider != null) {
            filter_params = map_from_url(filter_params, this.routeProvider);
            this.runbootstrap();
        }
    }

    String getAPIHost() {
        return API_HOST;
    }

    void runbootstrap() {
        this.active_filter_value = "${this.filter_params['active']}";
        print("Setting active_filter_value to $active_filter_value");
        this.searchconfig = this.filter_params['searchconfig'];
        wasteASecond().then((_) {
            updateS2Tags(this.filter_params['regions'], 'regions');
            updateS2Tags(this.filter_params['technologies'], 'technologies');
            updateS2Tags(this.filter_params['accounts'], 'accounts');
            updateS2Tags(this.filter_params['names'], 'names');
        });
    }

    void updateS2Tags(String filter, String id) {
        String s2id = '#s2_$id';
        String hidd = '#filter$id';
        if (filter != null && filter.length > 0) {
            filter = Uri.decodeComponent(filter);
            List<String> thelist = filter.split(',');
            var json = new JsObject.jsify(thelist);
            var select_box = context.callMethod('jQuery', [s2id]);
            select_box.callMethod('select2', ["val", json]);
            var hidden_field = context.callMethod('jQuery', [hidd]);
            hidden_field.callMethod('val', [select_box.callMethod('val')]);
        }
    }

    // Let angular have a second to ng-repeat through all the select2 options
    Future wasteASecond() {
        return new Future.delayed(const Duration(milliseconds: 250), () => "1");
    }

    void pushFilterRoutes() {
        _add_param(filter_params, 'regions');
        _add_param(filter_params, 'technologies');
        _add_param(filter_params, 'accounts');
        _add_param(filter_params, 'names');
        filter_params['active'] = param_to_url(active_filter_value);
        filter_params['searchconfig'] = param_to_url(searchconfig);
        filter_params['page'] = '1';
        router.go(result_type_binded, filter_params);
    }

    void _add_param(Map<String, String> param_map, param_name) {
        var domid = "filter$param_name";
        param_map[param_name] = param_to_url(querySelector("#$domid").attributes["value"]);
    }

    // These two methods, getFilterString() and getParamString(..) are for select2.
    String getFilterString() {
        String regions = getParamString("filterregions", "regions");
        String technologies = getParamString("filtertechnologies", "technologies");
        String accounts = getParamString("filteraccounts", "accounts");
        String names = getParamString("filternames", "names");
        String active = this.active_filter_value != "null" ? "&active=$active_filter_value" : "";
        String retval = "&$regions&$technologies&$accounts&$names$active";
        print("getFilterString returning $retval");
        return retval;
    }

    String getParamString(String param_name, String param_url_name) {
        String param_value = querySelector("#$param_name").attributes["value"];
        if (param_value == null) {
            param_value = "";
        }
        return "$param_url_name=$param_value";
    }
}
