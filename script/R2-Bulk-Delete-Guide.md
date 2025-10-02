# Cloudflare R2 批量刪除腳本使用指南

## 概述

這個 PowerShell 腳本可以批量刪除 Cloudflare R2 貯體中的所有物件，支援分頁處理，可以處理大量檔案。

## 功能特點

- ✅ **分頁支援**: 自動處理 API 分頁，確保刪除所有檔案
- ✅ **進度顯示**: 即時顯示刪除進度
- ✅ **錯誤處理**: 記錄失敗的刪除操作
- ✅ **安全確認**: 刪除前需要用戶確認
- ✅ **最終驗證**: 刪除完成後驗證貯體是否為空

## 使用前準備

### 1. 設置 Cloudflare API Token

```powershell
# 方法 1: 設置環境變數
$env:CLOUDFLARE_API_TOKEN = "YOUR_API_TOKEN_HERE"

# 方法 2: 使用 wrangler 登入
npx wrangler login
```

### 2. 獲取 Account ID

從 Cloudflare Dashboard 右側欄位複製 Account ID，或使用以下命令：

```powershell
npx wrangler whoami
```

## 腳本使用

### 基本用法

```powershell
# 使用預設設定 (Account ID 和貯體名稱已預設)
.\delete-all-with-pagination.ps1

# 或指定參數
.\delete-all-with-pagination.ps1 -AccountId "YOUR_ACCOUNT_ID" -BucketName "YOUR_BUCKET_NAME"
```

### 執行流程

1. **檢查 API Token**: 驗證 `CLOUDFLARE_API_TOKEN` 環境變數
2. **獲取所有物件**: 自動處理分頁，獲取貯體中所有物件
3. **顯示檔案清單**: 顯示前 5 個檔案的詳細資訊
4. **用戶確認**: 要求用戶輸入 'YES' 確認刪除
5. **批量刪除**: 逐個刪除所有物件
6. **進度報告**: 每刪除 10 個檔案顯示進度
7. **最終驗證**: 確認貯體是否已清空

## 腳本輸出範例

```
=== Complete R2 Delete Script (with Pagination) ===
Account ID: b6df93992d17685bcab2a54a9c9da654
Bucket Name: hodes-images
Found API Token
Getting all objects from bucket (handling pagination)...
Fetching page 1...
  Found 20 objects on page 1 (Total so far: 20)
  More pages available, continuing...
...
Found total 575 objects across 29 pages

First 5 objects:
  Key: 'assets/imgs/blog/Art_Nouveau/ad7hftxdivxxvm.cloudfront_32.jpg' Size: 743846 bytes
  Key: 'assets/imgs/blog/Art_Nouveau/ad7hftxdivxxvm.cloudfront_32.webp' Size: 195682 bytes
  ...

Confirm deletion of ALL 575 files?
Type 'YES' to continue:
YES

Starting deletion of all 575 objects...
Deleted 10/575 objects
Deleted 20/575 objects
...
Deleted 575/575 objects

=== Deletion Summary ===
Successfully deleted: 575
Failed: 0
All objects deleted successfully!

Performing final verification...
✅ Bucket is completely empty!
You can now delete the bucket:
npx wrangler r2 bucket delete hodes-images
```

## 刪除貯體

當所有物件都刪除完成後，可以使用以下命令刪除空的貯體：

```powershell
npx wrangler r2 bucket delete YOUR_BUCKET_NAME
```

## 故障排除

### 常見問題

1. **API Token 未設置**
   ```
   Error: CLOUDFLARE_API_TOKEN not found
   ```
   **解決方案**: 設置環境變數或使用 `npx wrangler login`

2. **權限不足**
   ```
   Failed to delete [filename]: [permission error]
   ```
   **解決方案**: 確保 API Token 具有 'Cloudflare R2:Edit' 權限

3. **網路問題**
   ```
   Error occurred: [network error]
   ```
   **解決方案**: 檢查網路連接，腳本會自動重試

### API 限制

- 腳本包含 50ms 的延遲以避免 API 速率限制
- 如果遇到速率限制錯誤，可以增加延遲時間

## 安全注意事項

⚠️ **重要提醒**:
- 此操作**不可逆**，請確保您真的想要刪除所有檔案
- 建議在刪除前備份重要檔案
- 腳本會要求明確的 'YES' 確認才會執行刪除

## 技術細節

### API 端點
- 列出物件: `GET /accounts/{account_id}/r2/buckets/{bucket_name}/objects`
- 刪除物件: `DELETE /accounts/{account_id}/r2/buckets/{bucket_name}/objects/{object_key}`

### 分頁處理
腳本自動處理 Cloudflare R2 API 的分頁機制：
- 每頁最多 20 個物件
- 使用 `cursor` 參數獲取下一頁
- 檢查 `is_truncated` 標誌判斷是否還有更多頁面

## 版本資訊

- **腳本版本**: 1.0
- **支援的 API**: Cloudflare R2 API v4
- **PowerShell 版本**: 5.0+
- **測試日期**: 2025-10-02

---

**創建者**: AI Assistant  
**最後更新**: 2025-10-02  
**適用於**: Cloudflare R2 批量物件刪除
