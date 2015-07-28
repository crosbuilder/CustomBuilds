diff --git a/app-arch/p7zip/p7zip-9.20.1-r5.ebuild b/app-arch/p7zip/p7zip-9.20.1-r5.ebuild
index 76e6799..e3c274f 100644
--- a/app-arch/p7zip/p7zip-9.20.1-r5.ebuild
+++ b/app-arch/p7zip/p7zip-9.20.1-r5.ebuild
@@ -94,6 +94,7 @@ src_prepare() {
 }
 
 src_compile() {
+	sed -e 's/-fno-exceptions//g' -i makefile.* || die
 	emake all3
 	if use kde || use wxwidgets; then
 		emake -- 7zG
