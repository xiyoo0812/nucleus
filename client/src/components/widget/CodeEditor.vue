
<template>
  <codemirror class="code-mirror" v-model="code" :options="cmOption" @ready="onCmReady" @input="onCmChange" ref="vcme"/>
</template>

<script>
  import { codemirror } from 'vue-codemirror'

  // languageuage
  import 'codemirror/mode/lua/lua.js'
  import 'codemirror/mode/yaml/yaml.js'
  import 'codemirror/mode/shell/shell.js'
  import 'codemirror/mode/javascript/javascript.js'
  import 'codemirror/mode/dockerfile/dockerfile.js'

  // theme css
  import 'codemirror/theme/monokai.css'

  // require active-line.js
  import'codemirror/addon/selection/active-line.js'

  // styleSelectedText
  import'codemirror/addon/selection/mark-selection.js'
  import'codemirror/addon/search/searchcursor.js'

  // hint
  import'codemirror/addon/hint/show-hint.js'
  import'codemirror/addon/hint/show-hint.css'
  import'codemirror/addon/hint/javascript-hint.js'
  import'codemirror/addon/selection/active-line.js'

  // highlightSelectionMatches
  import'codemirror/addon/scroll/annotatescrollbar.js'
  import'codemirror/addon/search/matchesonscrollbar.js'
  import'codemirror/addon/search/searchcursor.js'
  import'codemirror/addon/search/match-highlighter.js'

  // keyMap
  import'codemirror/mode/clike/clike.js'
  import'codemirror/addon/edit/matchbrackets.js'
  import'codemirror/addon/comment/comment.js'
  import'codemirror/addon/dialog/dialog.js'
  import'codemirror/addon/dialog/dialog.css'
  import'codemirror/addon/search/searchcursor.js'
  import'codemirror/addon/search/search.js'
  import'codemirror/keymap/sublime.js'

  // foldGutter
  import'codemirror/addon/fold/foldgutter.css'
  import'codemirror/addon/fold/brace-fold.js'
  import'codemirror/addon/fold/comment-fold.js'
  import'codemirror/addon/fold/foldcode.js'
  import'codemirror/addon/fold/foldgutter.js'
  import'codemirror/addon/fold/indent-fold.js'
  import'codemirror/addon/fold/markdown-fold.js'
  import'codemirror/addon/fold/xml-fold.js'
  
  export default {
    name: 'CodeEditor',
    components: {
      codemirror
    },
    props: {
        code: {
            type: String,
            default: ""
        },
        width: {
            type: String,
            default: null
        },
        height: {
            type: String,
            default: null
        },
        readOnly: {
            type: Boolean,
            default: false
        },
        language: {
            type: String,
            default: "text/x-sh"
        },
    },
    mounted() {
        this.cmOption.mode = this.language
        setTimeout(() => {
            this.styleSelectedText = true
            this.cmOption.styleActiveLine = true
            this.cmOption.readOnly = this.readOnly
        }, 1000)
    },
    data() {
      return {
        cmOption: {
          tabSize: 4,
          styleActiveLine: false,
          lineNumbers: true,
          styleSelectedText: false,
          line: true,
          foldGutter: true,
          gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
          highlightSelectionMatches: { showToken: /\w/, annotateScrollbar: true },
          mode: 'text/x-sh',
          hintOptions:{
            completeSingle: false
          },
          keyMap: "sublime",
          matchBrackets: true,
          showCursorWhenSelecting: true,
          theme: "monokai",
          extraKeys: { "Ctrl": "autocomplete" }
        }
      }
    },
    watch: {
      language() {
        this.cmOption.mode = this.language
      }
    },
    methods: {
      onCmReady() {
        if(this.width || this.height) {
          this.$refs.vcme.codemirror.setSize(this.width, this.height)
        }
      },
      onCmChange(curCode) {
        this.$emit("input", curCode)
      },
    }
  }
</script>

<style>
  .CodeMirror-focused .cm-matchhighlight {
    background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAFklEQVQI12NgYGBgkKzc8x9CMDAwAAAmhwSbidEoSQAAAABJRU5ErkJggg==);
    background-position: bottom;
    background-repeat: repeat-x;
  }
  .cm-matchhighlight {
    background-color: lightgreen;
  }
  .CodeMirror-selection-highlight-scrollbar {
    background-color: green;
  }
  .code-mirror{
    font-size : 13px;
    line-height : 150%;
    text-align: left;
  }
</style>