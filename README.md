# R2-Explorer App

[![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/cloudflare/templates/tree/main/r2-explorer-template)

## 🗑️ 批量刪除工具

這個專案包含一個強大的 PowerShell 腳本，可以批量刪除 Cloudflare R2 貯體中的所有物件：

- **腳本**: `delete-all-with-pagination.ps1`
- **文檔**: `R2-Bulk-Delete-Guide.md`
- **功能**: 支援分頁處理，可刪除大量檔案，包含進度顯示和錯誤處理

### 快速使用

```powershell
# 設置 API Token
$env:CLOUDFLARE_API_TOKEN = "YOUR_API_TOKEN"

# 執行批量刪除
.\delete-all-with-pagination.ps1
```

詳細使用說明請參考 [R2-Bulk-Delete-Guide.md](./R2-Bulk-Delete-Guide.md)

![R2 Explorer Template Preview](https://imagedelivery.net/wSMYJvS3Xw-n339CbDyDIA/e3c4ab7e-43f2-49df-6317-437f4ae8ce00/public)

<!-- dash-content-start -->

R2-Explorer 為您的 Cloudflare R2 儲存貯體帶來熟悉的 Google Drive 式介面，讓檔案管理變得簡單直觀。

## 主要功能

- **🔒 安全性**

  - 基本身份驗證支援
  - Cloudflare Access 整合
  - 在您的 Cloudflare 帳戶上自行託管

- **📁 檔案管理**

  - 拖放檔案上傳
  - 資料夾創建和組織
  - 大檔案的多部分上傳
  - 右鍵上下文選單提供進階選項
  - HTTP/自訂元資料編輯

- **👀 檔案處理**

  - 瀏覽器內檔案預覽
    - PDF 文件
    - 圖片
    - 文字檔案
    - Markdown
    - CSV
    - Logpush 檔案
  - 瀏覽器內檔案編輯
  - 資料夾上傳支援

- **📧 電子郵件整合**

  - 透過 Cloudflare Email Routing 接收和處理電子郵件
  - 直接在介面中查看電子郵件附件

- **🔎 可觀測性**
  - 使用 `wrangler tail` 查看與任何已部署 Worker 相關的即時日誌
  <!-- dash-content-end -->

> [!IMPORTANT]
> 使用 C3 創建此專案時，當詢問是否要部署時請選擇 "no"。您需要先遵循此專案的[設置步驟](https://github.com/cloudflare/templates/tree/main/r2-explorer-template#setup-steps)再進行部署。

## 開始使用

在此儲存庫外部，您可以使用 [C3](https://developers.cloudflare.com/pages/get-started/c3/)（`create-cloudflare` CLI）創建新專案：

```
npm create cloudflare@latest -- --template=cloudflare/templates/r2-explorer-template
```

此模板的即時公開部署可在 [https://demo.r2explorer.com](https://demo.r2explorer.com) 查看

## 設置步驟

1. 使用您選擇的套件管理器安裝專案相依性：
   ```bash
   npm install
   ```
2. 創建名為 "r2-explorer-bucket" 的 [R2 貯體](https://developers.cloudflare.com/r2/get-started/)：
   ```bash
   npx wrangler r2 bucket create r2-explorer-bucket
   ```
3. 部署專案！
   ```bash
   npx wrangler deploy
   ```
4. 監控您的 worker
   ```bash
   npx wrangler tail
   ```

## 下一步

預設情況下，此模板是**唯讀的**。

要啟用編輯功能，只需更新 `src/index.ts` 檔案中的 `readonly` 標誌。

強烈建議您先設置安全性，[了解更多](https://r2explorer.com/getting-started/security/)。
