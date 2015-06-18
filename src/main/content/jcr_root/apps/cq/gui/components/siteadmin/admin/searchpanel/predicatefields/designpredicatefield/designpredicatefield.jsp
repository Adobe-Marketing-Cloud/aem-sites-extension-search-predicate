<%--

ADOBE CONFIDENTIAL
__________________

Copyright 2015 Adobe Systems Incorporated
All Rights Reserved.

NOTICE:  All information contained herein is, and remains
the property of Adobe Systems Incorporated and its suppliers,
if any.  The intellectual and technical concepts contained
herein are proprietary to Adobe Systems Incorporated and its
suppliers and are protected by trade secret or copyright law.
Dissemination of this information or reproduction of this material
is strictly forbidden unless prior written permission is obtained
from Adobe Systems Incorporated.

--%><% 
%><%@include file="/libs/granite/ui/global.jsp" %><%
%><%@ page session="false" contentType="text/html" pageEncoding="utf-8"
         import="com.adobe.granite.ui.components.Config,
                 org.apache.sling.api.resource.Resource,
                 org.apache.sling.api.resource.ValueMap" %><%
    String metaType = "design";

    Resource facetRes = resourceResolver.getResource(slingRequest.getRequestPathInfo().getSuffix());
    Config facetsCfg = new Config(facetRes);
    String builderFacetsPath = facetsCfg.get("predicatesConfig", String.class);
    if(builderFacetsPath == null) {
        return;
    }
    String filterType = facetsCfg.get("filterType", String.class);

    Resource builderFacetsResource = resourceResolver.getResource(builderFacetsPath);
    if(builderFacetsResource == null || builderFacetsResource.getChild("items") == null) {
        return;
    }

    Resource configResource = builderFacetsResource.getChild("items/" + metaType);
    if(configResource == null) {
        return;
    }
    ValueMap configNode = configResource.adaptTo(ValueMap.class);
    String configResourceType = configNode.get("fieldResourceType", String.class);

    ValueMap fieldProperties = resource.adaptTo(ValueMap.class);
    Config cfg = new Config(resource);
    String key = resource.getName();

    String listOrder = cfg.get("listOrder", "");

    String resourceType = cfg.get("sling:resourceType", configResourceType);
%>
<input type="hidden" name="./items/<%= key %>">
<input type="hidden" name="./items/<%= key %>/jcr:primaryType" value="nt:unstructured">
<input type="hidden" name="./items/<%= key %>/sling:resourceType" value="<%= resourceType %>">
<input type="hidden" name="./items/<%= key %>/metaType" value="<%= metaType %>">
<input type="hidden" name="./items/<%= key %>/listOrder@Delete">
<input type="hidden" name="./items/<%= key %>/listOrder@TypeHint" value="String">
<input type="hidden" class="listOrder" name="./items/<%= key %>/listOrder" value="<%= listOrder %>">
<input type="hidden" name="./items/<%= key %>/text" value="<%= configNode.get("fieldLabel", "Design Predicate") %>">
<input type="hidden" name="./items/<%= key %>/fieldLabel" value="<%= configNode.get("fieldLabel", "Design Predicate") %>"><%
    if(filterType != null) {
%><input type="hidden" name="./items/<%= key %>/filterType" value="<%= filterType %>">
<input type="hidden" name="./items/<%= key %>/filterType@Delete">
<input type="hidden" name="./items/<%= key %>/filterType@TypeHint" value="String"><%
    }
%><div><h3><%= configNode.get("fieldTitle", "Design Predicate")%></h3></div>

<sling:include resource="<%= resource %>" resourceType="granite/ui/components/foundation/form/formbuilder/formfieldproperties/placeholderfields"/>

<%    request.setAttribute ("com.adobe.cq.datasource.propertyplaceholder", "eg. jcr:content/cq:designPath"); %>

<sling:include resource="<%= resource %>" resourceType="cq/gui/components/common/admin/customsearch/formbuilder/predicatefieldproperties/maptopropertyfield"/>

<sling:include resource="<%= resource %>" resourceType="granite/ui/components/foundation/form/formbuilder/formfieldproperties/titlefields"/>

<sling:include resource="<%= resource %>" resourceType="granite/ui/components/foundation/form/formbuilder/formfieldproperties/deletefields"/>