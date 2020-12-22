c = get_config()
c.TemplateExporter.extra_template_basedirs=['./slides-config']
c.Exporter.template_name = 'custom'
c.Exporter.preprocessors = ['nbconvert.preprocessors.TagRemovePreprocessor']
c.SlidesExporter.exclude_input_prompt: True
c.SlidesExporter.exclude_output_prompt: True
# c.resources.reveal.theme = 'simple'
