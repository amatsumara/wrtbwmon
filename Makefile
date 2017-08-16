# wrtbwmon

include $(TOPDIR)/rules.mk

PKG_NAME:=wrtbwmon
PKG_VERSION:=0.36
PKG_RELEASE:=3
PKG_MAINTAINER:= Alexander Koval <alex123@hades.in.ua>

include $(INCLUDE_DIR)/package.mk


define Package/$(PKG_NAME)
        SECTION:=net
        CATEGORY:=Network
	DEPENDS:=+busybox
        TITLE:=wrtbwmon is a small and basic shell script designed to run on linux powered routers
        PKGARCH:=all
endef


define Package/$(PKG_NAME)/description
wrtbwmon was designed to track bandwidth consumption on home routers.
It accomplishes this with iptables rules, which means you don't need to
run an extra process just to track bandwidth. wrtbwmon conveniently tracks
bandwidth consumption on a per-IP address basis, so you can easily
determine which user/device is the culprit.
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/files/
	$(CP) -r ./files/ $(PKG_BUILD_DIR)
	$(CP) ./postinst $(PKG_BUILD_DIR)
endef


define Build/Configure
endef


define Build/Compile
endef


define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/share/wrtbwmon
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./postinst $(1)/etc/uci-defaults/$(PKG_NAME)-postinst
	$(INSTALL_BIN) ./files/wrtbwmon $(1)/usr/sbin/wrtbwmon
	$(INSTALL_BIN) ./files/readDB.awk $(1)/usr/sbin/readDB.awk
	$(INSTALL_BIN) ./files/init/wrtbwmon $(1)/etc/init.d/wrtbwmon
	$(CP) $(PKG_BUILD_DIR)/files/{usage.htm1,usage.htm2} $(1)/usr/share/wrtbwmon
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
  echo 'This should run inside actual running system'
  (. /etc/uci-defaults/$(PKG_NAME)-postinst)
  rm -f /etc/uci-defaults/$(PKG_NAME)-postinst
fi
exit 0
endef


define Package/$(PKG_NAME)/postrm
#!/bin/sh
echo 'Removing dirs'
rm -r /usr/share/wrtbwmon
echo 'Cleaning up crontab'
crontab -u root -l | grep -v "wrtbwmon" > /tmp/crontab.tmp
crontab -u root /tmp/crontab.tmp
rm -f /tmp/crontab.tmp
endef


$(eval $(call BuildPackage,$(PKG_NAME)))



