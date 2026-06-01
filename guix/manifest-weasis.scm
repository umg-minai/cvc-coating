(use-modules (gnu packages)          ; specification->package
             (guix build-system trivial)
             (guix download)
             (guix gexp)
             (guix packages)
             (guix profiles)
             ((guix licenses) #:prefix license:))

;; Weasis is not packaged in Guix channels; define it inline from the upstream
;; Debian release.
;;
;; Strategy: unpack the .deb and patch RPATH only for the bundled JRE
;; directories (so the jpackage launcher and JVM find their own shared libs at
;; the new Guix store path).  The system interpreter (/lib64/ld-linux-x86-64)
;; is left intact so that GTK, X11, fontconfig, etc. are resolved via the
;; system ldconfig as they would be with a normal dpkg install.
(define weasis
  (package
    (name "weasis")
    (version "4.6.6")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://github.com/nroduit/Weasis/releases/download/v"
             version "/weasis_" version "-1_amd64.deb"))
       (sha256
        (base32 "1sdjxc7x4syml2sjd2j91frnlqpygg8djh754wxj6hc92l475z05"))))
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils)
                  (ice-9 ftw))
      #:builder
      #~(begin
          (use-modules (guix build utils)
                       (ice-9 ftw))
          (let* ((out       #$output)
                 (ar        (string-append
                             #$(this-package-native-input "binutils") "/bin/ar"))
                 (tar-prog  (string-append
                             #$(this-package-native-input "tar") "/bin/tar"))
                 (zstd-prog (string-append
                             #$(this-package-native-input "zstd") "/bin/zstd"))
                 (pe        (string-append
                             #$(this-package-native-input "patchelf") "/bin/patchelf"))
                 ;; Only the bundled JRE directories — system libs resolved via
                 ;; the original system interpreter using /etc/ld.so.cache.
                 (rpath     (string-join
                             (list (string-append out "/opt/weasis/lib")
                                   (string-append out "/opt/weasis/lib/runtime/lib")
                                   (string-append out "/opt/weasis/lib/runtime/lib/server"))
                             ":")))
            (mkdir-p out)
            ;; Unpack the .deb: ar → data.tar.zst → directory tree
            (invoke ar "x" #$source)
            (invoke zstd-prog "-d" "data.tar.zst" "-o" "data.tar")
            (invoke tar-prog "-xf" "data.tar" "-C" out)
            ;; Patch RPATH only — do NOT change the interpreter so that the
            ;; system glibc linker resolves GTK, X11, fontconfig, etc. via
            ;; the system /etc/ld.so.cache.
            (file-system-fold
             (const #t)
             (lambda (path stat result)
               (when (eq? 'regular (stat:type stat))
                 (false-if-exception
                  (invoke pe "--set-rpath" rpath path)))
               result)
             (const #t) (const #t) (const #t) (const #t)
             #t
             (string-append out "/opt/weasis"))
            ;; Expose the launcher on PATH.
            (mkdir-p (string-append out "/bin"))
            (symlink (string-append out "/opt/weasis/bin/Weasis")
                     (string-append out "/bin/weasis"))))))
    (native-inputs
     (list (specification->package "binutils")
           (specification->package "tar")
           (specification->package "zstd")
           (specification->package "patchelf")))
    (synopsis "DICOM viewer")
    (description
     "Weasis is a multipurpose standalone and web-based DICOM viewer with
support for DICOM, JPEG, PNG and many other formats.")
    (home-page "https://weasis.org")
    (license license:epl2.0)))

(packages->manifest
  (list weasis
        (specification->package "xdg-utils")))
