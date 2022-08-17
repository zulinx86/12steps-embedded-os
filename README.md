# 12 ステップで作る組込み OS 自作入門 - Work Log
## 動作確認環境
- OS: Ubuntu 18.04.6 LTS
- qemu-system-x86_64: version 2.11.1
- 基本方針
    - ソースコードのビルドは VM 上で行う。
    - ビルドの成果物は、ローカル環境にファイルコピーする。
    - ローカル環境から H8/3069F にシリアル通信する (ROM 書き込みや OS ファイルの XMODEM 転送など) 。


## ビルド環境構築
1. VM イメージのダウンロード ( https://kozos.jp/books/makeos/#vmimage )
    ```
    $ wget http://www2.kozos.jp/largefile/makeos-CentOS-20150504.ova
    ```
1. OVA 形式を QCOW2 形式に変換
    ```
    $ tar -xvf makeos-CentOS-20150504.ova
    makeos-CentOS-20150504.ovf
    makeos-CentOS-20150504-disk1.vmdk

    $ qemu-img convert -O qcow2 makeos-CentOS-20150504-disk1.vmdk 
    makeos-CentOS-20150504.qcow2

    $ rm makeos-CentOS-20150504-disk1.vmdk makeos-CentOS-20150504.ovf makeos-CentOS-20150504.ova
    ```
1. QEMU で VM の起動
    ```
    $ sudo qemu-system-x86_64 -m 4G -enable-kvm makeos-CentOS-20150504.qcow2
    ```
    - ユーザー名: root
    - パスワード: progtoolroot
1. 必要なものがインストールされているか確認
    ```
    # ls -l /usr/local/bin/h8300-elf-*
    ```
1. ソースコードのダウンロード・展開
    ```
    # wget https://kozos.jp/kozos/osbook/osbook_03.zip
    # unzip osbook_03.zip
    # rm osbook_03.zip
    ```
1. VM のシャットダウン  
    ```
    # shutdown -h now
    ```
1. 「h8write」のセットアップ ( http://mes.osdn.jp/h8/writer-j.html )
    ```
    $ wget http://mes.osdn.jp/h8/h8write.c
    $ gcc h8write.c -o h8write -Wall
    ```



## ローカル PC と VM イメージ間でのファイル移動


1. 必要なドライバーのロード
    ```
    # modprobe nbd
    ```
1. マウント (mount.sh)
    ```
    # qemu-nbd --connect=/dev/nbd0 ./makeos-CentOs-20150504.qcow2
    # mount /dev/vg_livecd/lv_root /mnt
    ```
1. ファイル移動 (cp コマンドなど)
1. アンマウント (umount.sh)
    ```
    # umount /mnt
    # vgchange -an vg_livecd
    # qemu-nbd --disconnect /dev/nbd0
    ```


## シリアル通信の準備
1. 設定ファイルの作成
    ```
    # minicom -s
    ```
    - 「Serial port setup」から以下のように設定する
        - Serial Device : /dev/ttyUSB0
        - Bps/Par/Bits : 9600 8N1
            - Speed : 9600
            - Data : 8
            - Parity : None
            - Stopbits : 1
        - Hardware Flow Control : No
        - Software Flow Control : No
    - 「File transfer protocols」から以下のように設定する
        - Use filename selection window : No
1. 設定結果を一応確認
    ```
    # cat /etc/minicom/minirc.dfl 
    # Machine-generated file - use "minicom -s" to change parameters.
    pu port             /dev/ttyUSB0
    pu baudrate         9600
    pu bits             8
    pu parity           N
    pu stopbits         1
    pu rtscts           No 
    pu xonxoff          No 
    pu fselw            No
    ```
1. シリアル接続
    ```
    # minicom -o
    ```
    - Ctrl-A + S: ファイル転送モード開始
    - Ctrl-A + X: minicom から抜ける


## 資料リンク
- [H8/3069F-ZTAT ハードウェアマニュアル](http://www.picosystems.net/dl/ds/device/HD64F3069.pdf)
- [Ｈ８／３０６９Ｆネット対応マイコンＬＡＮボード（完成品）: 組立キット(モジュール) 秋月電子通商-電子部品・ネット通販](https://akizukidenshi.com/catalog/g/gK-01271/)
