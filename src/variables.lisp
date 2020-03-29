(in-package :engels)

(defmacro with-hash (bindings hash-table &body body)
  (alexandria:once-only (hash-table)
    `(symbol-macrolet
         (,@(mapcar (lambda (binding)
                      (destructuring-bind (symbol &optional (key `',symbol) default)
                          (alexandria:ensure-list binding)
                        `(,symbol (gethash ,key ,hash-table ,default))))
                    bindings))
       ,@body)))


(defun set-default-variables ()
  (with-hash
      (
       ;; Basic stylings
       br
       xs-pad
       sm-pad
       md-pad
       lg-pad
       xlg-pad
       trans
       ;; Breakpoints
       small-breakpoint
       large-breakpoint
       ;; Colors     
       primary
       accent
       red
       yellow
       grey
       white
       black
       ;; Text
       text
       secondary
       disabled
       dividers
       ;; Links
       link-color
       link-hover-color
       ;; Font
       sans-serif
       serif
       monospace
       font-family
       ;; Typography
       font-size-base
       font-size-small
       font-size-h1
       font-size-h2
       font-size-h3
       font-size-h4
       font-size-h5
       font-size-h6
       line-height-base
       ;; Other
       border)
      lass:*vars*
    
    ;; Basic stylings
    (setf br "4px")
    (setf xs-pad "4px")
    (setf sm-pad "8px")
    (setf md-pad "16px")
    (setf lg-pad "20px")
    (setf xlg-pad "40px")
    (setf trans "0.3s")

    ;; Breakpoints
    (setf small-breakpoint "400px")
    (setf large-breakpoint "768px")

    ;; Colors
    (setf primary "#007bff")
    (setf accent "#64ffda")
    (setf red "#f44336")
    (setf yellow "#ffeb3b")
    (setf grey "#f7f7f9")
    (setf white "#fff")
    (setf black "#000")

    ;; Text
    (setf text "rgba(0, 0, 0, 0.8)")
    (setf secondary "rgba(0, 0, 0, 0.54)")
    (setf disabled "rgba(0, 0, 0, 0.38)")
    (setf dividers "rgba(0, 0, 0, 0.12)")

    ;; Links
    (setf link-color primary)
    (setf link-hover-color (darken link-color 0.15))

    ;; Font
    (setf sans-serif "-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif,'Apple Color Emoji','Segoe UI Emoji','Segoe UI Symbol'")
    (setf serif "Georgia, Times, 'Times New Roman', serif")
    (setf monospace "Menlo, Monaco, Consolas, 'Courier New', monospace")
    (setf font-family sans-serif)

    ;; Typography
    (let ((font-size 16))
      (setf font-size-base (format nil "~Apx" font-size))
      (setf font-size-small (format nil "~Apx" (ceiling (* font-size 0.85)))))
    (setf font-size-h1 "40px")
    (setf font-size-h2 "32px")
    (setf font-size-h3 "28px")
    (setf font-size-h4 "24px")
    (setf font-size-h5 "20px")
    (setf font-size-h6 "16px")
    (setf line-height-base 1.5)
    ;; Other
    (setf border (concatenate 'string "1px solid " dividers))))
