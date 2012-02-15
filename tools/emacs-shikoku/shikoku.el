(require 'cl)
(require 'url)
(require 'deferred)
(require 'json)

(defun my-highlight-ruby ()
  (interactive)
(deferred:$
  (deferred:url-post
    "http://127.0.0.1:9393/"
     `((body ,(buffer-string)) (mime_type . "application/ruby")))

  (deferred:nextc it
    (lambda (buf)
      (let* (
             (json-object-type 'hash-table)
             (json-array-type 'list)
             (res (with-current-buffer buf (json-read-from-string (buffer-string))))
             (tokens (gethash "tokens" res))
             (index-from 0)
             )
        (dolist (token tokens)
          (let* (
                 (token-value (gethash "value" token))
                 (token-length (length (string-as-unibyte token-value)))
                 (token-color (gethash "color" token))
                 (index-end (+ index-from token-length))
                 (ovl (make-overlay index-from index-end))
                 )
            (overlay-put ovl 'face `(foreground-color . , token-color))
            (print token-value)
            (print (length token-value))
            (print (length (string-as-unibyte token-value)))
            (setq index-from index-end)
            ))
        (kill-buffer buf)))))
)
