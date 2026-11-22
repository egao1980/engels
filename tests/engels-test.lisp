(in-package #:engels/tests)

;;; Helpers

(defun selectors-text (node)
  (format nil "~{~a~^,~}" (mapcar (lambda (s) (css:selector-text s :pretty nil))
                                  (css:rule-selectors node))))

(defun top-rules ()
  (css:stylesheet-rules (engels:stylesheet)))

(defun find-rule (selectors &optional (nodes (top-rules)))
  "The first style rule whose minified selector list is SELECTORS."
  (find-if (lambda (n) (and (typep n 'css:rule) (string= selectors (selectors-text n))))
           nodes))

(defun rule-css (node &key (pretty t))
  (css:write-stylesheet (css:make-stylesheet (list node)) :pretty pretty))

(defun decl-value (rule property)
  (let ((d (find property (css:rule-declarations rule)
                 :key #'css:declaration-property :test #'string=)))
    (and d (css:declaration-value d))))

(defun lines (&rest lines)
  (format nil "~{~a~%~}" lines))

(defun file-text (pathname)
  (with-open-file (in pathname :external-format :utf-8)
    (let ((s (make-string (file-length in))))
      (subseq s 0 (read-sequence s in)))))

(defparameter +button+
  "button,input[type=\"submit\"],input[type=\"reset\"],input[type=\"button\"]")

;;; Compiling

(deftest compiles-without-conditions
  (let ((seen '()))
    (handler-bind (((or warning css:css-error)
                     (lambda (c) (push c seen))))
      (css-backend-lass:compile-lass-file (engels:source-pathname)))
    (ok (null seen) "no warning or css-error while compiling src/engels.lass")
    (ok (typep (engels:stylesheet) 'css:stylesheet))
    (ok (> (length (top-rules)) 80))))

(deftest key-selectors-exist
  (dolist (selectors (list "body" "p" "h1,h2,h3,h4,h5,h6" "a" "a:hover,a:focus"
                           "table" "caption" "thead th" "th,td" "tfoot td"
                           "label" "fieldset" "legend" "textarea" "select"
                           "select:not([size]):not([multiple])"
                           +button+
                           (format nil "~{~a:hover~^,~}"
                                   '("button" "input[type=\"submit\"]"
                                     "input[type=\"reset\"]" "input[type=\"button\"]"))
                           "input:not([type])" "input[type=\"color\"]"
                           "code" "pre" "blockquote" "hr" "img" "mark" "sup" "sub"
                           "main" "footer" "footer p"))
    (ok (find-rule selectors) selectors))
  (let ((forms (find-if (lambda (n) (and (typep n 'css:rule)
                                         (search "select,textarea,input[type=\"text\"]"
                                                 (selectors-text n))))
                        (top-rules))))
    (ok forms "the text-like form controls rule")
    (ok (search "input[type=\"tel\"]" (selectors-text forms)))))

(deftest canvas-vocabulary
  (dolist (selectors '("[data-layout=\"stack\"]" "[data-layout=\"row\"]" "[data-layout=\"grid\"]"
                       "[data-layout][data-gap=\"none\"]" "[data-layout][data-gap=\"s\"]"
                       "[data-layout][data-gap=\"l\"]"
                       "[data-layout=\"grid\"][data-columns=\"1\"]"
                       "[data-layout=\"grid\"][data-columns=\"6\"]"
                       "[data-align=\"start\"]" "[data-align=\"center\"]" "[data-align=\"end\"]"
                       "[data-badge]" "[data-badge=\"info\"]" "[data-badge=\"ok\"]"
                       "[data-badge=\"warn\"]" "[data-badge=\"error\"]"
                       "[aria-invalid=\"true\"]" "small[role=\"alert\"]"
                       "th[aria-sort=\"ascending\"]::after"
                       "[role=\"tablist\"] [role=\"tab\"][aria-selected=\"true\"]"))
    (ok (find-rule selectors) selectors))
  (ok (equal "\" \\25b2\"" (decl-value (find-rule "th[aria-sort=\"ascending\"]::after") "content"))))

;;; Theme

(deftest theme-has-both-modes
  (let* ((nodes (top-rules))
         (root (find-rule ":root" nodes))
         (media (find-if (lambda (n) (typep n 'css:media-rule)) nodes))
         (dark (find-rule ":root[data-theme=\"dark\"]" nodes))
         (light (find-rule ":root[data-theme=\"light\"]" nodes)))
    (ok (eq root (first nodes)) "the theme comes first")
    (ok (equal "light dark" (decl-value root "color-scheme")))
    (ok (equal "#007bff" (decl-value root "--engels-primary")))
    (ok (equal "(prefers-color-scheme: dark)" (css:media-rule-query media)))
    (let ((inner (first (css:at-rule-rules media))))
      (ok (equal ":root:not([data-theme=\"light\"])" (selectors-text inner)))
      (ok (equal "#4da3ff" (decl-value inner "--engels-primary"))))
    (ok (equal "dark" (decl-value dark "color-scheme")))
    (ok (equal "#16181d" (decl-value dark "--engels-bg")))
    (ok (equal "light" (decl-value light "color-scheme")))))

(deftest theme-block-is-the-css-protocol-theme
  (let* ((theme-sheet (css:css-theme-stylesheet (engels:theme)))
         (n (length (css:stylesheet-rules theme-sheet))))
    (ok (= 4 n))
    (ok (string= (css:write-stylesheet theme-sheet)
                 (css:write-stylesheet
                  (css:make-stylesheet (subseq (top-rules) 0 n)))))))

(deftest palettes-match
  (ok (equal (mapcar #'first engels:*light-palette*)
             (mapcar #'first engels:*dark-palette*))
      "same names, same order")
  (let ((text (engels:css :minify t))
        (defined (mapcar #'car (engels:palette-colours engels:*light-palette*))))
    (loop for start = (search "var(--" text) then (search "var(--" text :start2 (1+ start))
          while start
          do (let* ((name-start (+ start 6))
                    (name (subseq text name-start (position #\) text :start name-start))))
               (unless (member name defined :test #'string=)
                 (fail (format nil "var(--~a) has no theme property" name)))))
    (ok t "every var(--…) is defined by the theme")))

(deftest colour-helpers-match-the-old-engels-css
  ;; css/engels.css 0.1.0 (classie) printed these; the colour maths is unchanged.
  (let ((light (engels:palette-colours engels:*light-palette*)))
    (flet ((c (name) (cdr (assoc (concatenate 'string "engels-" name) light :test #'string=))))
      (ok (equal "#0062CC" (c "primary-active")) "darken 10% (button active, a:hover)")
      (ok (equal "#0062CC" (c "link-hover")))
      (ok (equal "#0069D9" (c "primary-hover")) "darken 7.5% (button hover)")
      (ok (equal "#005CBF" (c "primary-active-border")) "darken 12.5%")
      (ok (equal "#80BDFF" (c "input-focus-border")) "mix with #fff")
      (ok (equal "#EA1C0D" (c "red-dark")) "darken red 10%")
      ;; 0.1.0 printed rgba(0.00, 123.00, 255.00, 0.25): same colour, integer channels now
      (ok (equal "rgba(0, 123, 255, 0.25)" (c "input-focus-ring")))
      (ok (equal "rgba(0, 123, 255, 0.5)" (c "focus-ring")))))
  (let ((dark (engels:palette-colours engels:*dark-palette*)))
    (ok (equal "#73B7FF" (cdr (assoc "engels-primary-hover" dark :test #'string=)))
        "dark states lighten")
    (ok (equal "#366293" (cdr (assoc "engels-input-focus-border" dark :test #'string=)))))
  (ok (equal "14.00px" (decl-value (find-rule "sup") "font-size")) "ceiling (* 16px 0.85)"))

;;; Output

(deftest output-is-deterministic
  (let ((a (engels:css :minify t)))
    (ok (string= a (engels:css :minify t)))
    (ok (string= a (css:write-stylesheet
                    (css-backend-lass:compile-lass-file (engels:source-pathname))
                    :pretty nil))
        "a fresh compile prints the same text")
    (ok (string= (engels:css) (engels:css)))
    (ok (string= a (file-text (asdf:system-relative-pathname "engels" "css/engels.css")))
        "css/engels.css is (css :minify t)")))

(deftest css-and-octets
  (let ((pretty (engels:css))
        (mini (engels:css :minify t))
        (octets (engels:css-octets)))
    (ok (find #\Newline pretty))
    (ok (null (find #\Newline mini)))
    (ok (typep octets '(vector (unsigned-byte 8))))
    (ok (equalp octets (encoding-protocol:encode mini :encoding :utf-8)))
    (ok (= (length mini) (length octets)) "ASCII only")))

(deftest offline-and-html-safe
  (let ((text (engels:css)))
    (ok (null (search "url(" text)))
    (ok (null (search "@import" text)))
    (ok (null (search "</" text)))))

(deftest golden-rules
  (ok (string= (lines "a:hover, a:focus {"
                      "  color: var(--engels-link-hover);"
                      "  text-decoration: underline;"
                      "}")
               (rule-css (find-rule "a:hover,a:focus"))))
  (ok (string= (lines "body {"
                      "  background-color: var(--engels-bg);"
                      "  color: var(--engels-text);"
                      "  font-family: -apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif,'Apple Color Emoji','Segoe UI Emoji','Segoe UI Symbol';"
                      "  font-size: 16px;"
                      "  line-height: 1.5;"
                      "}")
               (rule-css (find-rule "body"))))
  (ok (string= (lines "blockquote {"
                      "  border-left: 2px solid var(--engels-text);"
                      "  font-family: Georgia, Times, 'Times New Roman', serif;"
                      "  font-style: italic;"
                      "  margin: 16px 0;"
                      "  padding-left: 16px;"
                      "}")
               (rule-css (find-rule "blockquote"))))
  (ok (string= "select:not([size]):not([multiple]){height:calc(2.25rem + 2px)}"
               (rule-css (find-rule "select:not([size]):not([multiple])") :pretty nil))
      "calc passes through")
  (ok (string= (concatenate 'string
                            "button:focus,input[type=\"submit\"]:focus,input[type=\"reset\"]:focus,"
                            "input[type=\"button\"]:focus{outline:0;box-shadow:0 0 0 0.2rem var(--engels-focus-ring)}")
               (rule-css (find-rule (format nil "~{~a:focus~^,~}"
                                            '("button" "input[type=\"submit\"]"
                                              "input[type=\"reset\"]" "input[type=\"button\"]")))
                         :pretty nil)))
  (ok (string= (lines "@media screen and (max-width:400px) {"
                      "  article, section, aside {"
                      "    clear: both;"
                      "    display: block;"
                      "    max-width: 100%;"
                      "  }"
                      "}")
               (rule-css (find-if (lambda (n) (and (typep n 'css:media-rule)
                                                   (search "400px" (css:media-rule-query n))
                                                   (search "article"
                                                           (selectors-text
                                                            (first (css:at-rule-rules n))))))
                                  (top-rules))))))

;;; Pruning (what canvas freeze will do)

(deftest used-rules-keeps-the-theme
  (let* ((tree (list (html-protocol:make-html-element
                      "p" :children (list (html-protocol:make-html-element "a")))))
         (used (css:stylesheet-rules (css:used-rules (engels:stylesheet) tree))))
    (ok (find-rule ":root" used) "root-like selectors always kept")
    (ok (find-if (lambda (n) (typep n 'css:media-rule)) used))
    (ok (find-rule "p" used))
    (ok (find-rule "a:hover,a:focus" used))
    (ok (null (find-rule "table" used)))
    (ok (find-rule "[data-badge]" used) "attribute selectors count as satisfied (conservative)")
    (ok (< (length used) (length (top-rules))))))
