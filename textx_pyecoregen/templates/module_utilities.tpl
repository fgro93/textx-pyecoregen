{% import '{pyecoregen}module_utilities.tpl' as ecore_modutil with context -%}

{%- macro generate_enum(e) %}
{%- for c in element.eClassifiers if c is type(ecore.EEnum) -%}
{% if c == e and loop.first %}

EEnum.default_value = property(lambda self: None)
{% endif -%}
{% endfor -%}
{{ ecore_modutil.generate_enum(e) }}
{{ e.name }}.__name__ = '{{ e.name }}'
{% endmacro %}

{#- -------------------------------------------------------------------------------------------- -#}

{%- macro generate_edatatype(e) %}
{{ ecore_modutil.generate_edatatype(e) }}
{{ e.name }}.__name__ = '{{ e.name }}'
{% endmacro %}

{#- -------------------------------------------------------------------------------------------- -#}

{%- macro generate_class_init(c) %}
    def __init__(self{{ ecore_modutil.generate_class_init_args(c) }}, **kwargs):
        super().__init__(**kwargs)
    {%- for feature in c.eStructuralFeatures | reject('type', ecore.EReference) %}
    {{ ecore_modutil.generate_feature_init(feature) }}
    {%- endfor %}
    {%- for feature in c.eStructuralFeatures | select('type', ecore.EReference) %}
    {{ ecore_modutil.generate_feature_init(feature) }}
    {%- endfor %}
{%- endmacro %}

{#- -------------------------------------------------------------------------------------------- -#}

{%- macro generate_class(c) %}
{% if element.eClassifiers[0] == c %}
class EObject(Ecore.EObject):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        for key, value in kwargs.items():
            if key not in self.__dict__:
                setattr(self, key, value)
{% endif %}

{% if not user_module %}{% for d in c.eStructuralFeatures | selectattr('derived') | selectattr('many') %}
{{ ecore_modutil.generate_derived_collection(d) }}
{% endfor %}{% endif %}

{% if c.abstract %}@abstract
{% endif -%}
{{ ecore_modutil.generate_class_header(c) }}
{%- for a in c.eAttributes %}
    {{ ecore_modutil.generate_attribute(a) -}}
{% endfor %}
{%- for r in c.eReferences %}
    {{ ecore_modutil.generate_reference(r) -}}
{% endfor %}
{% if not user_module %}{% for d in c.eStructuralFeatures | selectattr('derived') | rejectattr('many') %}
    {{ ecore_modutil.generate_derived_single(d) }}
{% endfor %}{% endif %}
{{- generate_class_init(c) }}
{% if not user_module %}{% for o in c.eOperations %}
    {{ ecore_modutil.generate_operation(o) }}
{% endfor %}{% endif %}
{%- endmacro %}

{#- -------------------------------------------------------------------------------------------- -#}

{%- macro generate_mixin(c) %}
{{ ecore_modutil.generate_mixin(c) }}
{%- endmacro %}
