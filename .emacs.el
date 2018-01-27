;;
;; should work with Emacs 24.5 and higher
;;
;; inspired from https://gist.github.com/nilsdeppe/7645c096d93b005458d97d6874a91ea9

;; Always start emacs server
(server-start)

;; plugins directory
(add-to-list 'load-path (expand-file-name "~/.emacs.d/plugins"))

;; instead of typing yes or no all the time, accept y and n
(defalias 'yes-or-no-p 'y-or-n-p)

;; disable autosave
;; (setq auto-save-default nil)

;; disable menubar (always)
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; don't ring the bell
(setq ring-bell-function 'ignore)

;; non-nil means draw cursor block as wide as the glyph under it
;; for example, for a tab, it will be drawn as wide as the displayed tab
(setq x-stretch-cursor t)

;; don't ask to follow symlink in git ?
;; (setq vc-follow-symlinks)

;; check on save whether file edited contains a #!shebang. and if so, make executable
;; http://mbork.pl/2015-01-10_A_few_random_Emacs_tips
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

;; Highlight some keywors in prog-mode
(add-hook 'prog-mode-hook
	  (lambda ()
	    (font-lock-add-keywords
	     nil
	     '(("\\<\\(FIXME\\|TODO\\|BUG\\|DONE\\)" 1 font-lock-warning-face t)
	       )
	     )
	    )
	  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set packages to install
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))

(package-initialize)
;; list the packages you want
(defvar package-list
  '(
    ;;;; emacsclient stuff
    with-editor

    ;;;;emacs mode developer tools
    ;;async
    ;;dash
    ;;helm
    ;;s
    ;;f

    ;;;; package management
    ;; epl

    ;;;; modes
    clang-format
    cmake-mode
    cuda-mode
    eyebrowse
    exec-path-from-shell
    ;;flycheck
    ;;flycheck-pyflakes
    ;;flycheck-ycmd
    ;; flymake-cppcheck
    ;; flymake-cpplint
    git-commit
    gitconfig-mode
    gitignore-mode
    gitattributes-mode
    google-c-style
    jinja2-mode
    json-mode
    magit
    markdown-mode
    protobuf-mode
    yaml-mode
    ;; smartparens
    ;; ycmd

    ;; highlight stuff
    ;; highligh-indentation-mode

    ;;;; indent stuff
    ;;; aggressive-indent-mode

    ;;;; jump around
    ;;avy

    ;;;; project manipulation / interaction
    ;; projectile

    ;; themes
    color-theme
    color-theme-sanityinc-solarized
    clues-theme
    solarized-theme
    zenburn-theme
    sublime-themes
    tao-theme
    )
  )

;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))
;; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remove trailing white space upon saving
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically compile and save ~/.emacs.el
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun byte-compile-init-files (file)
  "Automatically compile FILE."
  (interactive)
  (save-restriction
    ;; Suppress the warning when you setq an undefined variable.
    (if (>= emacs-major-version 23)
	(setq byte-compile-warnings '(not free-vars obsolete))
      (setq byte-compile-warnings
	    '(unresolved callargs redefine obsolete noruntime cl-warnings interactive-only)))
    (byte-compile-file (expand-file-name file)))
  )

(add-hook
 'after-save-hook
 (function (lambda ()
	     (if (string= (file-truename (expand-file-name "~/.emacs.el"))
			  (file-truename (buffer-file-name)))
		 (byte-compile-init-files "~/.emacs.el"))
	     )
	   )
 )

;; Byte-compile again to ~/.emacs.elc if it is outdated
(if (file-newer-than-file-p (expand-file-name "~/.emacs.el")
			    (expand-file-name "~/.emacs.elc"))
    (byte-compile-init-files "~/.emacs.el"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO : I Need platform specific stuff
;;        - chrome/crouton : rebind keys around Chrome browser controls
;;        - macosx : interaction with terminal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; general tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(show-paren-mode t)
(setq column-number-mode t)

;; prevents the creation of backup files with tilde
;; (setq make-backup-files nil)
;; toolbar is useless, disable it
(if (functionp 'tool-bar-mode) (tool-bar-mode -1))
;;;; autorepair at closing brace, braket and quote?
;;(require 'autorepair)
;;(autorepair-global-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; default modes configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python-mode and PEP-8 settings (tabs vs spaces)

;; cc-mode ?
(require 'cc-mode)

;; Change tab key behavior to insert spaces instead
(setq-default indent-tabs-mode nil)

;; Set the number of spaces that the tab key inserts (usually 2 or 4)
(setq c-basic-offset 4)
;; Set the size that a tab CHARACTER is interpreted as
;; (unnecessary if there are no tab characters in the file!)
(setq tab-width 4)

;; We want to be able to see if there is a tab character vs a space.
;; global-whitespace-mode allows us to do just that.
;; Set whitespace mode to only show tabs, not newlines/spaces.
;;(require 'whitespace)
;;(setq whitespace-style '(tabs tab-mark))
;; Turn on whitespace mode globally.
;;(global-whitespace-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; configure packages
;;;; for readability respect order of package-list
;;;; eventually reorder packages in package-list if there are dependencies
;;;; or even better, avoid dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; with-editor
;;

;;
;; clang-format
;;
;; clang-format can be triggered using C-c C-f
;; Create clang-format file using google style
;; clang-format -style=google -dump-config > .clang-format
(require 'clang-format)
(global-set-key (kbd "C-c C-f") 'clang-format-region)

;;
;; cmake-mode
;;
(require 'cmake-mode)
;;
;; cuda-mode
;;

;;
;; eyebrowse
;;

;;
;; google-c-style
;;
;; Enable Google style things
;; This prevents the extra two spaces in a namespace that Emacs otherwise wants to put... Gawd!
(add-hook 'c-mode-common-hook 'google-set-c-style)

;; Autoindent using google style guide
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;; Enable hide/show of code blocks
(add-hook 'c-mode-common-hook 'hs-minor-mode)

;;
;; jinja2 mode
;;
(require 'jinja2-mode)
(setq auto-mode-alist (cons '("\\.jinja$"   . jinja2-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.jinja2$"  . jinja2-mode) auto-mode-alist))

;;
;; json mode
;;
(require 'json-mode)
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))

;;
;; markdown-mode
;;
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
;(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
;(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))


;;
;; protobuf-mode
;;
;; seems to cause compilation problems
;;(require 'protobuf-mode)
;;(add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-mode))

;;
;; yaml mode
;;
(setq auto-mode-alist (cons '("\\.yaml$" . yaml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.yml$"  . yaml-mode) auto-mode-alist))


;;
;; smartparens package
;;
;;(require 'smartparens-config)
;;(add-hook 'c++-mode-hook #'smartparens-mode)
;;(add-hook 'cuda-mode-hook #'smartparens-mode)
;;(add-hook 'json-mode-hook #'smartparens-mode)
;;(add-hook 'python-mode-hook #'smartparens-mode)


;;
;; Package: ycmd (YouCompleteMeDaemon)
;;
;; Set up YouCompleteMe for emacs:
;; https://github.com/Valloric/ycmd
;; https://github.com/abingham/emacs-ycmd

;;(require 'ycmd)
;;(add-hook 'after-init-hook #'global-ycmd-mode)
;;(set-variable 'ycmd-server-command '("python" "/home/nils/Research/ycmd/ycmd"))
;;(set-variable 'ycmd-extra-conf-whitelist '("~/.ycm_extra_conf.py"))
;;(set-variable 'ycmd-global-config "~/.ycm_extra_conf.py")
;;(setq ycmd-force-semantic-completion t)

;;
;;
;;
(require 'clues-theme)
(load-theme 'clues t)

(provide '.emacs)
;;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("c48551a5fb7b9fc019bf3f61ebf14cf7c9cdca79bcb2a4219195371c02268f11"
     "599f1561d84229e02807c952919cd9b0fbaa97ace123851df84806b067666332"
     "58c6711a3b568437bab07a30385d34aacf64156cc5137ea20e799984f4227265"
     "4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4"
     "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328"
     "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0"
     "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4"
     "72a81c54c97b9e5efcc3ea214382615649ebb539cb4f2fe3a46cd12af72c7607"
     "0e0c37ee89f0213ce31205e9ae8bce1f93c9bcd81b1bcda0233061bb02c357a8"
     "e0d42a58c84161a0744ceab595370cbe290949968ab62273aed6212df0ea94b4"
     "9b59e147dbbde5e638ea1cde5ec0a358d5f269d27bd2b893a0947c4a867e14c1"
     "b3775ba758e7d31f3bb849e7c9e48ff60929a792961a2d536edec8f68c671ca5"
     "8ec2e01474ad56ee33bc0534bdbe7842eea74dccfb576e09f99ef89a705f5501"
     default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background nil)))))
