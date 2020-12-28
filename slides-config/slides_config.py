c = get_config()
c.TemplateExporter.extra_template_basedirs=['./slides-config']
c.Exporter.template_name = 'custom'
c.TemplateExporter.exclude_input_prompt = True
c.TemplateExporter.exclude_output_prompt = True
# c.resources.reveal.theme = 'simple'
