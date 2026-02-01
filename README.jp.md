# DTV-All-in-One Docker
[English README](./README.md)

Docker を使用して、**ソースコードのビルド、環境構築、チャンネルスキャンをすべて自動化**するシンプルなプロジェクトです。

## 概要
このプロジェクトは、DTV（デジタルテレビ放送）環境を構築したい方向けのフルオートメーション環境を提供します。シンプルなスクリプトを実行するだけで、使い捨てのコンテナ内で全コンポーネントをソースからビルドし、最適化された一つのランタイムイメージに統合します。

### 特徴
* **完全自動化:** ソースのコンパイルから環境構築まで、単一のスクリプトでシームレスに処理します。
* **スマートアップデート:** 既存の EPG データや録画履歴を保持したまま、ツール群のみを最新の状態に更新できます。
* **Docker ベース:** ホスト OS を汚すことなく、すべてが隔離されたコンテナ内で動作します。
* **すぐに利用可能:** 自動チャンネルスキャン機能が含まれているため、構築後すぐに視聴・録画が始められます。

## 統合ツール
以下のツールが自動的にビルドされ、協調動作するように設定されます。
* **Mirakurun:** ISDB チューナーサーバー
* **EDCB:** 録画予約・EPG 管理
* **EDCB_Material_WebUI:** EDCB 用のモダンな Web インターフェース
* **BonDriver_LinuxMirakc:** Mirakurun と EDCB を接続するブリッジ
* **ISDBScanner:** チャンネルスキャン自動化ユーティリティ
* **recisdb-rs:** Rust 製録画コマンドラインツール
* **libaribb25:** ARIB STD-B25 デコードライブラリ
* **KonomiTV:** モダンな TV 視聴 Web インターフェース

## 使い方

### 前提条件
* Docker / Docker Compose
* ホストマシンに DTV チューナーのドライバがインストールされていること

### 初期セットアップ
環境に合わせたセットアップスクリプトを実行してください。ツールのビルドと初期設定（チャンネルスキャンを含む）が自動的に行われます。

**Windows:**
```powershell
.\setup.bat
```

**Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

### ツールの更新
EPG データや録画履歴を維持したまま、ツール群のみを最新バージョンに更新する場合：

**Windows:**
```powershell
.\update.bat
```

**Linux:**
```bash
./update.sh
```

## ライセンス & クレジット

### プロジェクトライセンス
このプロジェクトは **GNU General Public License v3.0 (GPLv3)** の下で公開されています。  
**recisdb-rs (GPLv3)** との統合、および本環境の性質を考慮し、コンプライアンスの遵守とオープンソースの協力促進のため GPLv3 を採用しています。

### サードパーティソフトウェア・クレジット
本プロジェクトは以下のソフトウェアのインストールを自動化しています。各ソフトウェアのライセンスを尊重してご利用ください。

| ソフトウェア | ライセンス |
| :--- | :--- |
| **[Mirakurun](https://github.com/Chinachu/Mirakurun)** | Apache License 2.0 |
| **[EDCB](https://github.com/xtne6f/EDCB)** | Civetweb / Lua License |
| **[EDCB_Material_WebUI](https://github.com/EMWUI/EDCB_Material_WebUI)** | Free |
| **[BonDriver_LinuxMirakc](https://github.com/matching/BonDriver_LinuxMirakc)** | MIT License |
| **[ISDBScanner](https://github.com/tsukumijima/ISDBScanner)** | MIT License |
| **[recisdb-rs](https://github.com/kazuki0824/recisdb-rs)** | GNU GPL v3.0 |
| **[libaribb25](https://github.com/tsukumijima/libaribb25)** | Apache License 2.0 |
| **[KonomiTV](https://github.com/tsukumijima/KonomiTV)** | MIT License |

### 免責事項
* **自己責任:** 本プロジェクトは「現状のまま」提供され、いかなる保証もありません。利用は自己責任で行ってください。
* **法令遵守:** 利用者は、放送の受信および録画に際し、現地の著作権法および ARIB 規格を遵守する責任を負います。
* **バイナリ配布の禁止:** 本リポジトリは公式ソースから取得してビルドするスクリプトを提供するものであり、著作物であるバイナリそのものの配布は行っていません。
