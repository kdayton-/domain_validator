module TranslationsHelpers
  def with_error_translation(subject, type, message, &block)
    translations = {
      :activemodel => {
        :errors => {
          :models => {
            subject.model_name.singular => {
              :attributes => {
                :domain => {
                  type => message
                }
              }
            }
          }
        }
      }
    }

    with_translations(translations, &block)
  end

  def with_translations(translations)
    original_backend = I18n.backend

    I18n.backend = I18n::Backend::KeyValue.new(Hash.new, true)
    I18n.backend.store_translations(I18n.locale, translations)

    yield
  ensure
    I18n.backend = original_backend
  end
end
