# LibreTranslate.sh

A wrapper for using LibreTranslate on ShellScript. It only depends on curl and jq.

Paste the function into your script and use it.


## Example

```bash

# <Copy libretranslate.sh here>

export LIBRETRANSLATE_URL="https://translate.argosopentech.com/"
export LIBRETRANSLATE_APIKEY="XXXXXX"


libre_translate_detect "こんにちは" # Result: ja

libre_translate_translate "Translate text on your shell!" en fr # Result: Traduisez le texte sur votre coquille !

```

## Usage

### libre_translate_detect <Text>

Detect the language of a single text.

If error, returns an error message with an exit code of 1.

### libre_translate_languages

Retrieve list of supported languages

### libre_translate_translate <Text> <Source Lang> <Target Lang>

Translate text from a language to another

If error, returns an error message with an exit code of 1.

### libre_translate_translate_auto <Text> <Target Lang>

Automatically detect and translate the language of the source.

If error, returns an error message with an exit code of 1.
