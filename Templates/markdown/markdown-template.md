
# {{page.title}}
{{#page.specifications}}
{{#values}}{{>ObjectSpecification}}{{/values}}
{{/page.specifications}}

{{#object.comment}}{{#hasLongDescription}}
## {{strings.objectOverview.title}}
{{#longDescription}}
{{>GBCommentComponentsList}}
{{/longDescription}}
{{/hasLongDescription}}
{{/object.comment}}

{{#object.methods}}
{{#hasSections}}
## {{strings.objectTasks.title}}
{{#sections}}
{{>TaskTitle}}
{{#methods}}
{{>TaskMethod}}
{{/methods}}
{{/sections}}
{{/hasSections}}
{{/object.methods}}

{{#object.methods}}
{{#hasProperties}}
## {{strings.objectMethods.propertiesTitle}}
{{#properties}}
{{>Method}}
{{/properties}}
{{/hasProperties}}
{{#hasClassMethods}}
<a title="{{strings.objectMethods.classMethodsTitle}}" name="class_methods"></a>
## {{strings.objectMethods.classMethodsTitle}}
{{#classMethods}}
{{>Method}}
{{/classMethods}}
{{/hasClassMethods}}
{{#hasInstanceMethods}}
<a title="{{strings.objectMethods.instanceMethodsTitle}}" name="instance_methods"></a>
## {{strings.objectMethods.instanceMethodsTitle}}
{{#instanceMethods}}
{{>Method}}
{{/instanceMethods}}
{{/hasInstanceMethods}}
{{/object.methods}}

{{#typedefEnum}}
### {{nameOfEnum}}
{{#comment}}
{{#hasLongDescription}}
{{#longDescription}}{{>GBCommentComponentsList}}{{/longDescription}}
{{/hasLongDescription}}
{{/comment}}
{{#constants}}
#### Definition
    typedef {{enumStyle}}({{enumPrimitive}}, {{nameOfEnum}} ) {   
        {{#constants}}
        {{name}}{{#hasAssignedValue}} = {{assignedValue}}{{/hasAssignedValue}},
        {{/constants}}
    };
{{/constants}}
{{#constants}}
#### Constants
{{#constants}}
{{>Constant}}
{{/constants}}
{{/constants}}
{{#comment}}
{{#hasAvailability}}
#### {{strings.objectMethods.availability}}
{{#availability}}{{>GBCommentComponentsList}}{{/availability}}
{{/hasAvailability}}
{{#hasRelatedItems}}
#### {{strings.objectMethods.seeAlsoTitle}}
{{#relatedItems.components}}
* `{{>GBCommentComponent}}`
{{/relatedItems.components}}
{{/hasRelatedItems}}
{{#prefferedSourceInfo}}
#### {{strings.objectMethods.declaredInTitle}}
`{{filename}}`
{{/prefferedSourceInfo}}
{{/comment}}
{{/typedefEnum}}

{{#typedefBlock}}
<a title="{{strings.objectMethods.blockDefTitle}}" name="instance_methods"></a>
## {{strings.objectMethods.blockDefTitle}}
{{>BlocksDefList}}
{{/typedefBlock}}







Section ObjectSpecification
&nbsp;&nbsp;**{{title}}** {{#values}}{{#href}}<a href="{{&href}}">{{/href}}{{string}}{{#href}}</a>{{/href}}{{&delimiter}}  
{{/values}}
EndSection

Section GBCommentComponentsList
{{#components}}{{>GBCommentComponent}}{{/components}}
EndSection

Section GBCommentComponent
{{&htmlValue}}
EndSection

Section TaskTitle
{{#hasMultipleSections}}
### {{#sectionName}}{{.}}{{/sectionName}}{{^sectionName}}{{strings.objectTasks.otherMethodsSectionName}}{{/sectionName}}
{{/hasMultipleSections}}
{{^hasMultipleSections}}
### {{#sectionName}}{{.}}{{/sectionName}}
{{/hasMultipleSections}}
EndSection

Section TaskMethod
[{{>TaskSelector}}]({{htmlLocalReference}}) {{#isProperty}}*{{strings.objectTasks.property}}*{{/isProperty}} {{#isRequired}}*{{strings.objectTasks.requiredMethod}}*{{/isRequired}}  
EndSection

Section TaskSelector
{{#isInstanceMethod}}&ndash;&nbsp;{{/isInstanceMethod}}{{#isClassMethod}}+&nbsp;{{/isClassMethod}}{{#isProperty}}&nbsp;&nbsp;{{/isProperty}}{{methodSelector}}
EndSection


Section Method
<a name="{{htmlReferenceName}}" title="{{methodSelector}}"></a>
### {{methodSelector}}
{{#comment}}
{{#hasShortDescription}}
{{#shortDescription}}{{>GBCommentComponent}}{{/shortDescription}}
{{/hasShortDescription}}
{{/comment}}
`{{>MethodDeclaration}}`
{{#comment}}
{{#hasMethodParameters}}
#### {{strings.objectMethods.parametersTitle}}
{{#methodParameters}}
*{{argumentName}}*  
&nbsp;&nbsp;&nbsp;{{#argumentDescription}}{{>GBCommentComponentsList}}{{/argumentDescription}}  
{{/methodParameters}}
{{/hasMethodParameters}}
{{#hasMethodResult}}
#### {{strings.objectMethods.resultTitle}}
{{#methodResult}}{{>GBCommentComponentsList}}{{/methodResult}}
{{/hasMethodResult}}
{{#hasAvailability}}
#### {{strings.objectMethods.availability}}
{{#availability}}{{>GBCommentComponentsList}}{{/availability}}
{{/hasAvailability}}
{{#hasLongDescription}}
#### {{strings.objectMethods.discussionTitle}}
{{#longDescription}}{{>GBCommentComponentsList}}{{/longDescription}}
{{/hasLongDescription}}
{{#hasMethodExceptions}}
#### {{strings.objectMethods.exceptionsTitle}}
{{#methodExceptions}}
*{{argumentName}}*  
&nbsp;&nbsp;&nbsp;{{#argumentDescription}}{{>GBCommentComponentsList}}{{/argumentDescription}}  
{{/methodExceptions}}
{{/hasMethodExceptions}}
{{#hasRelatedItems}}
#### {{strings.objectMethods.seeAlsoTitle}}
{{#relatedItems.components}}
* `{{>GBCommentComponent}}`
{{/relatedItems.components}}
{{/hasRelatedItems}}
{{#prefferedSourceInfo}}
#### {{strings.objectMethods.declaredInTitle}}
* `{{filename}}`
{{/prefferedSourceInfo}}
{{/comment}}
EndSection

Section MethodDeclaration
{{#formattedComponents}}{{#emphasized}}*{{/emphasized}}{{#href}}<a href="{{&href}}">{{/href}}{{value}}{{#href}}</a>{{/href}}{{#emphasized}}*{{/emphasized}}{{/formattedComponents}}
EndSection


Section Constant
<a name="{{htmlReferenceName}}" title="{{name}}"></a><code>{{name}}</code>
{{#comment}}
{{#hasShortDescription}}
{{#shortDescription}}{{>GBCommentComponent}}{{/shortDescription}}
{{/hasShortDescription}}
{{#hasAvailability}}
Available in {{#availability}}{{#components}}{{stringValue}}{{/components}}{{/availability}}
{{/hasAvailability}}
{{/comment}}
{{#prefferedSourceInfo}}
&nbsp;&nbsp;&nbsp;{{strings.objectMethods.declaredInTitle}} `{{filename}}`.
{{/prefferedSourceInfo}}
EndSection




Section BlocksDefList
### {{nameOfBlock}}
{{#comment}}
{{#hasShortDescription}}
{{#shortDescription}}{{>GBCommentComponent}}{{/shortDescription}}
{{/hasShortDescription}}
{{/comment}}
<code>typedef {{returnType}} (^{{nameOfBlock}}) ({{&htmlParameterList}})</code>
{{#comment}}
{{#hasLongDescription}}
#### {{strings.objectMethods.discussionTitle}}
{{#longDescription}}{{>GBCommentComponentsList}}{{/longDescription}}
{{/hasLongDescription}}
{{/comment}}
{{#comment}}
{{#hasAvailability}}
#### {{strings.objectMethods.availability}}
{{#availability}}{{>GBCommentComponentsList}}{{/availability}}
{{/hasAvailability}}
{{#hasRelatedItems}}
#### {{strings.objectMethods.seeAlsoTitle}}
{{#relatedItems.components}}
* <code>{{>GBCommentComponent}}</code>
{{/relatedItems.components}}
{{/hasRelatedItems}}
{{#prefferedSourceInfo}}
#### {{strings.objectMethods.declaredInTitle}}
<code class="declared-in-ref">{{filename}}</code>
{{/prefferedSourceInfo}}
{{/comment}}
EndSection
