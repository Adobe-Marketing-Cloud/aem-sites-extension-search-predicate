/*
 * ADOBE CONFIDENTIAL
 *
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 */

(function (document, $) {
    "use strict";

    /*
     * Add a coral-TagList-tag to the coral-TagList.
     */
    function addTag(design, groupName, propertyPath, $tagList) {
        var i = $tagList.children("li").length,
            $listItem = $('<li role="listitem" class="coral-TagList-tag coral-TagList-tag--multiline"/>').attr('title', design.title)
                .append($('<button class="coral-MinimalButton coral-TagList-tag-removeButton js-DesignPredicate-removeButton" type="button"/>').attr('title', Granite.I18n.get("Remove"))
                    .append($('<i class="coral-Icon coral-Icon--sizeXS coral-Icon--close"/>')))
                .append($('<span class="coral-TagList-tag-label">').text(design.title))
                .append($('<input type="hidden" name="' + groupName + '.' + i + '_property.value" value="' + design.path + '">'))
                .append($('<input type="hidden" name="' + groupName + '.' + i + '_property" value="' + propertyPath + '">'))
                .append($('<input type="hidden" name="' + groupName + '.' + i + '_property.breadcrumbs" value="' + design.title + ' {${$value}}">'));
        // handle tag deletion.
        $(".js-DesignPredicate-removeButton", $listItem).on("click", function(event) {
            event.preventDefault();
            $tagList.data("tagList").removeItem(design.path);
            submit($(".searchpanel"));
        });
        $tagList.append($listItem);
        // add to internal storage
        if($tagList.data("tagList")) {
        	$tagList.data("tagList")._existingValues.push(design.path);
        } 
    }

    function containsTag($tagList, value) {
        var values = $tagList.data("tagList").getValues();
        if($.inArray(value, values) > -1 || value.length === 0) {
            return true;
        }
        return false;
    }

    function isInDesignSubtree(path) {
        var tokens = path.split("/"),
            index = $.inArray("designs", tokens);
        if (index > -1 && index < tokens.length -1) {
            return true;
        }
        return false;
    }

    function submit($form) {
        $form.find('input[type=hidden]').each(function () {
            this.disabled = !($(this).val());
        });
        $form.submit();
    }

    function endsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }

    $(document).ready(function () {
        var $form = $(".searchpanel"),
            $dataField = $('.design-predicate input.js-coral-pathbrowser-input'),
            $designPredicate = $dataField.closest(".coral-PathBrowser"),
            $tagLists = $('.design-predicate .coral-TagList.js-coral-Autocomplete-tagList'),
            ns = "designpredicate";

        $(document).off('loadSavedQuery.' + ns).on('loadSavedQuery.' + ns, function (evt, queryParameters) {
            $designPredicate.each(function () {
                var $tagList = $(this).siblings('.coral-TagList'),
                    predicateName = $(this).data("group"),
                    propertyPath = $(this).data("property-path");

                var designs = [];
                $.each(queryParameters, function(key, value) {
                    if(key.indexOf(predicateName) == 0 && endsWith(key, "_property") && value === propertyPath) {
                        var design = {},
                            breadcrumbsVal = queryParameters[key + ".breadcrumbs"];
                        design['path'] = queryParameters[key + ".value"];
                        design['title'] = breadcrumbsVal.substring(0, breadcrumbsVal.indexOf("{${$value}}"));
                        designs.push(design);
                    }
                });
                console.log("Andreea:"+designs.length);
                for (var i = 0; i < designs.length; i++) {
                    addTag(designs[i], predicateName, propertyPath, $tagList);
                }
            });
        });

        $(document).off('resetSearchFilters.' + ns).on('resetSearchFilters.' + ns, function (evt) {
            $tagLists.each(function( index, element ){
                var tagList = $(this).data("tagList"),
                    values = tagList.getValues();
                $.each(values, function( index, value ){
                    tagList.removeItem(value);
                });
            });
            $designPredicate.val("");
        });

        $designPredicate.each(function () {

            var designBrowser = $(this).data("pathBrowser");

            /**
             * Submit form when selecting a directory path from PathBrowser picker
             */
            designBrowser.$picker.off("coral-pathbrowser-picker-confirm." + ns).on("coral-pathbrowser-picker-confirm." + ns, function (e) {
                var predicateInput = designBrowser.inputElement,
                    $designPredContainer = $(predicateInput).closest(".design-predicate"),
                    $designPred = $(predicateInput).closest(".coral-PathBrowser"),
                    selections = $(this).find(".coral-ColumnView").data("columnView").getSelectedItems();
                if(selections.length > 0) {
                    $.each(selections, function() {
                        var selectedElem = this.item;
                        var $tagList = $designPredContainer.find(".coral-TagList.js-coral-Autocomplete-tagList"),
                            design = {
                                title: selectedElem.find(".coral-ColumnView-label").text(),
                                path: selectedElem.data("value")
                            },
                            predicateName = $designPred.data("group"),
                            propertyPath = $designPred.data("property-path");
                        if(containsTag($tagList, design.path)) {
                            $(predicateInput).val("");
                            return;
                        }
                        addTag(design, predicateName, propertyPath, $tagList);
                    });
                    $(predicateInput).val("");
                    submit($form);
                    //reset picker selections since they are not synchronized yet with the autocomplete
                    $(".coral-ColumnView-item.is-active.is-selected", $(this)).toggleClass('is-active is-selected');
                }
            });

            /**
             * Submit form when selecting a directory path from autocomplete SelectList
             */
            designBrowser.dropdownList.off("selected." + ns).on("selected." + ns, function (e) {
                var $designPredContainer = $(this).closest(".design-predicate"),
                    $designPred = $designPredContainer.find(".coral-PathBrowser"),
                    predicateInput = $designPred.data("pathBrowser").inputElement;
                if(e.selectedValue) {
                    if(isInDesignSubtree(e.selectedValue)) {
                        var selectedElem = $(this).find("li[data-value='" + e.selectedValue + "']");
                        var $tagList = $designPredContainer.find(".coral-TagList.js-coral-Autocomplete-tagList");
                        var design = {
                                title: selectedElem.text(),
                                path: selectedElem.data("value")
                            },
                            predicateName = $designPred.data("group"),
                            propertyPath = $designPred.data("property-path");
                        if(containsTag($tagList, design.path)) {
                            $(predicateInput).val("");
                            return;
                        }
                        addTag(design, predicateName, propertyPath, $tagList);
                        $(predicateInput).val("");
                        submit($form);
                    }
                }
            });

        });

    });

})(document, Granite.$);
