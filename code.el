(load "~/.emacs.d/straight/repos/llm/llm.el")
(load "~/.emacs.d/straight/repos/llm/llm-ollama.el")
(load "~/.emacs.d/straight/repos/ellama/ellama.el")

(require 'ellama)
(require 'llm)
(require 'llm-ollama)

(setopt ellama-coding-provider
	(make-llm-ollama
	 ;;	 :chat-model "qwen2.5-coder"
	 	 :chat-model "temp1"
	 :embedding-model "nomic-embed-text"
	 :default-chat-non-standard-params '(("num_ctx" . 32768))))
