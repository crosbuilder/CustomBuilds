#!/bin/bash

# ebuildにパッチ当てをする(audio/mp3対策 )
cd ~/trunk/src/overlays/overlay-${BOARD}
patch -p1 < ~/myenv/patches/chromeos-chrome/enable_codec.diff
if [ $? -ne 0 ]; then
  echo Failed to apply patch. Abort.
  exit 1
fi

