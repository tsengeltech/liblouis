((c-mode
  (tab-width   . 4)
  (fill-column . 90)
  (eval
   . (progn
       (defun clang-format-lineup-arglist (_)
         (let ((containing (cadr c-syntactic-element))
               (openparen (car (cddr c-syntactic-element))))
           (vector
            (+ (* 2 c-basic-offset)
               (save-excursion
                 (goto-char openparen)
                 (if (save-excursion (forward-sexp) (looking-at "[\s\t\n]*[\{;]"))
                     (goto-char containing)
                   (unless (= containing openparen)
                     (unless (save-excursion (skip-chars-backward " \t\n") (looking-back "[=!&\|]"))
                       (ignore-errors
                         (backward-sexp)
                         (when (looking-at "if[\s\t\n]*(")
                           (goto-char containing))))
                     (when (looking-back "!")
                       (backward-char))))
                 (current-column))))))
       (c-add-style
        "liblouis"
        '((indent-tabs-mode . nil)
          (tab-width        . 4)
          (c-basic-offset   . 4)
          (c-offsets-alist  (arglist-cont          . 0)
                            (arglist-cont-nonempty . clang-format-lineup-arglist)
                            (arglist-intro         . clang-format-lineup-arglist)
                            (arglist-close         . ++)
                            (statement-cont        . ++)
                            (brace-list-intro      . +)
                            (brace-list-entry      . (lambda (elem)
                                                       (save-excursion
                                                         (goto-char (cdr elem))
                                                         (let ((boi (c-point 'boi)))
                                                           (if (= boi (point))
                                                               0
                                                             (goto-char boi)
                                                             (vector (+ c-basic-offset (current-column))))))))
                            (substatement-open     . 0)
                            (brace-list-open       . 0)
                            (label                 . 0)
                            (inextern-lang         . 0))
          (c-hanging-braces-alist (defun-open before after)
                                  (defun-close before after)
                                  (substatement-open)
                                  (arglist-cont-nonempty)
                                  (block-close before after)))
        t)))))
