<%--
  ADOBE CONFIDENTIAL

  Copyright 2014 Adobe Systems Incorporated
  All Rights Reserved.

  NOTICE:  All information contained herein is, and remains
  the property of Adobe Systems Incorporated and its suppliers,
  if any.  The intellectual and technical concepts contained
  herein are proprietary to Adobe Systems Incorporated and its
  suppliers and may be covered by U.S. and Foreign Patents,
  patents in process, and are protected by trade secret or copyright law.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe Systems Incorporated.
--%><%
%><%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false" contentType="text/html" pageEncoding="utf-8"
          import="com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.ComponentHelper.Options,
                  com.adobe.granite.ui.components.Tag,
                  com.adobe.granite.ui.components.ds.ValueMapResource,
                  org.apache.jackrabbit.util.Text,
                  org.apache.sling.api.resource.ValueMap,
                  org.apache.sling.api.wrappers.ValueMapDecorator,
                  java.util.ArrayList,
                  java.util.HashMap,
                  java.util.List,
                  com.day.cq.wcm.api.Template,
                  org.apache.sling.api.resource.Resource"%><%
%><%@taglib prefix="ui" uri="http://www.adobe.com/taglibs/granite/ui/1.0"%><%

    Config cfg = new Config(resource);
    long predicateIndex = cfg.get("listOrder", 6000L);
    String predicateName = "group";
    
    Tag tag = cmp.consumeTag();
    AttrBuilder attrs = tag.getAttrs();
    attrs.addClass("coral-Form-fieldwrapper design-predicate coral-Search--cqSearchPanel");
    attrs.addOthers(cfg.getProperties(), "class");

    List<String> values = new ArrayList<String>();
    for (String parameterName : slingRequest.getRequestParameterMap().keySet()) {
        if (parameterName.matches("[0-9]+_property$")) {
            values.add(slingRequest.getRequestParameter(parameterName).toString());
        }
    }

    String propertyPath = cfg.get("name", "jcr:content/cq:designPath");
    boolean tagsOr = cfg.get("tagsOr",true);

    predicateName = predicateIndex + "_" + predicateName;

    String predicate = cfg.get("predicate", "hierarchyNotFile");
    String rootPath = cfg.get("rootPath", "/etc/designs");

    ValueMap pathBrowserProperties = new ValueMapDecorator(new HashMap<String, Object>());
    pathBrowserProperties.put("emptyText", cfg.get("emptyText", i18n.get("Select Design")));
    pathBrowserProperties.put("class", "coral-Form-field");
    pathBrowserProperties.put("rootPath", rootPath);
    pathBrowserProperties.put("pickerMultiselect", true);
    pathBrowserProperties.put("predicate", predicate);
    pathBrowserProperties.put("pickerTitle", i18n.get("Select Design"));
    pathBrowserProperties.put("property-path", xssAPI.encodeForHTMLAttr(propertyPath));
    pathBrowserProperties.put("group", xssAPI.encodeForHTMLAttr(predicateName));
    ValueMapResource valueMapResource = new ValueMapResource(resourceResolver, resource.getPath(), "granite/ui/components/foundation/form/pathbrowser", pathBrowserProperties);
%><div <%= attrs.build() %>><%
    if (tagsOr) { %>
    <input type="hidden" name="<%=predicateName%>.p.or" value="true"><%
    }

    cmp.include(valueMapResource, new Options().rootField(false));
    %>
    <ul class="coral-TagList js-coral-Autocomplete-tagList" role="listbox" data-init='taglist'></ul>
</div>
<ui:includeClientLib categories="cq.siteadmin.admin.searchpanel.designpredicate" />
