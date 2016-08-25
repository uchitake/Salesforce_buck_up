public with sharing class SalesAnalyticsController {

    // 商品コード
    public static final String PRODUCT_CODE_PROPER = '01'; 
    public static final String PRODUCT_CODE_OUTSOURCING = '02'; 
    public static final String PRODUCT_CODE_OTHERS = '99'; 

    // 対応月フォーマット
    public static final String MONTH_FORMAT = 'yyyy/MM';

    // 分類
    public static final String TYPE_FORECAST = '予測';
    public static final String TYPE_PERFORMANCE = '実績';

    // 売上予測リスト
    public Map<String, PredictedValue__c> salesForecastMap{get; set;}

    // 売上実績リスト
    public Map<String, PredictedValue__c> salesPerformanceMap{get; set;}

    // 商談ID
    public String opportunityId {get; set;}

    // 明細未作成フラグ
    public Boolean unCreatedFlg {get; set;}

    // 明細未反映フラグ
    public Boolean unReflectedFlg {get; set;}

    public SalesAnalyticsController(ApexPages.StandardController controller) {
        System.debug('◆◆◆◆SalesAnalyticsController:START');

        // 初期化
        salesForecastMap = new Map<String, PredictedValue__c>();
        salesPerformanceMap = new Map<String, PredictedValue__c>();
        unCreatedFlg = false;
        unReflectedFlg = false;
        
        // 商談ID保管
        opportunityId =controller.getId();
        
        // 商談商品取得
        List<OpportunityLineItem> opportunityLineItemList = new List<OpportunityLineItem>();
        opportunityLineItemList = [
            SELECT PricebookEntry.Product2.Name
                 , ProductCode
                 , ServiceDate
                 , pt__c
                 , UnitPrice
                 , Discount
                 , uriage__c
                 , orderNo__c
              FROM OpportunityLineItem
             WHERE Opportunity.Id = :controller.getId()
        ];

        // 商談商品集計
        for(OpportunityLineItem opportunityLineItem : opportunityLineItemList) {

            // 初期化
            PredictedValue__c salesForecast = new PredictedValue__c();
            
            // Date型にはformat関数がないため、Datetime型に変換してフォーマットする
            Date serviceDate = opportunityLineItem.ServiceDate;
            Datetime serviceDatetime = Datetime.newInstance(serviceDate.year(), serviceDate.month(), serviceDate.day());
        
            // Mapに存在すればPTと売上加算
            if (salesForecastMap.containsKey(serviceDatetime.format(MONTH_FORMAT))) {
                // Mapのデータを書き戻す
                    salesForecast.sales_prediction_proper_stacked__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).sales_prediction_proper_stacked__c;
                    salesForecast.sales_prediction_outsourcing_stacked__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).sales_prediction_outsourcing_stacked__c;
                    salesForecast.sales_prediction_other__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).sales_prediction_other__c;
                    salesForecast.expense_prediction_proper_stacked__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).expense_prediction_proper_stacked__c;
                    salesForecast.expense_prediction_outsourcing_stacked__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).expense_prediction_outsourcing_stacked__c;
                    salesForecast.expense_prediction_other__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).expense_prediction_other__c;
                    salesForecast.v_revenue_prediction_proper_stacked__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).v_revenue_prediction_proper_stacked__c;
                    salesForecast.v_revenue_prediction_outsourcing_stacked__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).v_revenue_prediction_outsourcing_stacked__c;
                    salesForecast.v_revenue_prediction_other__c = salesForecastMap.get(serviceDatetime.format(MONTH_FORMAT)).v_revenue_prediction_other__c;
                    salesForecast.uriageNengetsu__c = serviceDate;
                    salesForecast.orderNo__c = opportunityLineItem.orderNo__c;
                
                // プロパ
                if (opportunityLineItem.ProductCode == PRODUCT_CODE_PROPER) {
                    salesForecast.sales_prediction_proper_stacked__c += opportunityLineItem.uriage__c;
                    salesForecast.expense_prediction_proper_stacked__c += opportunityLineItem.pt__c;
                    salesForecast.v_revenue_prediction_proper_stacked__c = salesForecast.sales_prediction_proper_stacked__c - salesForecast.expense_prediction_proper_stacked__c;

                // 外注
                } else if (opportunityLineItem.ProductCode == PRODUCT_CODE_OUTSOURCING) {
                    salesForecast.sales_prediction_outsourcing_stacked__c += opportunityLineItem.uriage__c;
                    salesForecast.expense_prediction_outsourcing_stacked__c += opportunityLineItem.pt__c;
                    salesForecast.v_revenue_prediction_outsourcing_stacked__c = salesForecast.sales_prediction_outsourcing_stacked__c - salesForecast.expense_prediction_outsourcing_stacked__c;
                
                // その他
                } else if (opportunityLineItem.ProductCode == PRODUCT_CODE_OTHERS) {
                    salesForecast.sales_prediction_other__c += opportunityLineItem.uriage__c;
                    salesForecast.expense_prediction_other__c += opportunityLineItem.pt__c;
                    salesForecast.v_revenue_prediction_other__c = salesForecast.sales_prediction_other__c - salesForecast.expense_prediction_other__c;
                }
                
                // 予測合計
                salesForecast.v_sales_prediction_stacked__c = salesForecast.sales_prediction_proper_stacked__c + salesForecast.sales_prediction_outsourcing_stacked__c + salesForecast.sales_prediction_other__c;
                salesForecast.v_expense_prediction_stacked__c = salesForecast.expense_prediction_proper_stacked__c + salesForecast.expense_prediction_outsourcing_stacked__c + salesForecast.expense_prediction_other__c;
                salesForecast.v_revenue_prediction_stacked__c = salesForecast.v_sales_prediction_stacked__c - salesForecast.v_expense_prediction_stacked__c;
                
            } else {
                // データをリセットする
                    salesForecast.sales_prediction_proper_stacked__c = 0;
                    salesForecast.sales_prediction_outsourcing_stacked__c = 0;
                    salesForecast.sales_prediction_other__c = 0;
                    salesForecast.expense_prediction_proper_stacked__c = 0;
                    salesForecast.expense_prediction_outsourcing_stacked__c = 0;
                    salesForecast.expense_prediction_other__c = 0;
                    salesForecast.v_revenue_prediction_proper_stacked__c = 0;
                    salesForecast.v_revenue_prediction_outsourcing_stacked__c = 0;
                    salesForecast.v_revenue_prediction_other__c = 0;
                    salesForecast.orderNo__c = opportunityLineItem.orderNo__c;
                    
                // 年月セット
                    salesForecast.uriageNengetsu__c = serviceDate;
                    
                // プロパ
                if (opportunityLineItem.ProductCode == PRODUCT_CODE_PROPER) {
                    salesForecast.sales_prediction_proper_stacked__c = opportunityLineItem.uriage__c;
                    salesForecast.expense_prediction_proper_stacked__c = opportunityLineItem.pt__c;
                    salesForecast.v_revenue_prediction_proper_stacked__c = opportunityLineItem.uriage__c - opportunityLineItem.pt__c;

                // 外注
                } else if (opportunityLineItem.ProductCode == PRODUCT_CODE_OUTSOURCING) {
                    salesForecast.sales_prediction_outsourcing_stacked__c = opportunityLineItem.uriage__c;
                    salesForecast.expense_prediction_outsourcing_stacked__c = opportunityLineItem.pt__c;
                    salesForecast.v_revenue_prediction_outsourcing_stacked__c = opportunityLineItem.uriage__c - opportunityLineItem.pt__c;
                
                // その他
                } else if (opportunityLineItem.ProductCode == PRODUCT_CODE_OTHERS) {
                    salesForecast.sales_prediction_other__c = opportunityLineItem.uriage__c;
                    salesForecast.expense_prediction_other__c = opportunityLineItem.pt__c;
                    salesForecast.v_revenue_prediction_other__c = opportunityLineItem.uriage__c - opportunityLineItem.pt__c;
                }
                
                // 予測合計
                salesForecast.v_sales_prediction_stacked__c = opportunityLineItem.uriage__c;
                salesForecast.v_expense_prediction_stacked__c = opportunityLineItem.pt__c;
                salesForecast.v_revenue_prediction_stacked__c = opportunityLineItem.uriage__c - opportunityLineItem.pt__c;
            }
            
            salesForecastMap.put(serviceDatetime.format(MONTH_FORMAT), salesForecast);
        }

        // 売上予測取得
        List<PredictedValue__c> salesForcastList = [
            SELECT uriageNengetsu__c
                 , common_sales_stacked__c
                 , common_sales_proper_stacked__c
                 , common_sales_outsourcing_stacked__c
                 , common_sales_others__c
                 , common_cost_stacked__c
                 , common_cost_proper_stacked__c
                 , common_cost_outsourcing_stacked__c
                 , common_cost_others__c
                 , common_revenue_stacked__c
                 , common_revenue_proper_stacked__c
                 , common_revenue_outsourcing_stacked__c
                 , common_revenue_others__c
              FROM PredictedValue__c
             WHERE opportunity_ref__r.Id = :controller.getId() 
               AND type__c = :TYPE_FORECAST
        ];
        
        // 明細未作成判定
        if (salesForecastMap.size() != 0 && salesForcastList.size() == 0) {
            unCreatedFlg = true;

        } else if (salesForecastMap.size() != 0) {
            // 商談商品と売上分析の対応月不一致
            if (salesForecastMap.size() != salesForcastList.size()) {
                unReflectedFlg = true;
            } else {
            
                for (PredictedValue__c salesForcast : salesForcastList) {
                    // Date型にはformat関数がないため、Datetime型に変換してフォーマットする
                    Date salesDate = salesForcast.uriageNengetsu__c;
                    Datetime salesDatetime = Datetime.newInstance(salesDate.year(), salesDate.month(), salesDate.day());
    
                    // 明細未反映判定
                    if (
                        salesForecastMap.get(salesDatetime.format(MONTH_FORMAT)) == null
                        || salesForecastMap.get(salesDatetime.format(MONTH_FORMAT)).sales_prediction_proper_stacked__c != salesForcast.common_sales_proper_stacked__c
                        || salesForecastMap.get(salesDatetime.format(MONTH_FORMAT)).expense_prediction_proper_stacked__c != salesForcast.common_cost_proper_stacked__c
                        || salesForecastMap.get(salesDatetime.format(MONTH_FORMAT)).sales_prediction_outsourcing_stacked__c != salesForcast.common_sales_outsourcing_stacked__c
                        || salesForecastMap.get(salesDatetime.format(MONTH_FORMAT)).expense_prediction_outsourcing_stacked__c != salesForcast.common_cost_outsourcing_stacked__c
                        || salesForecastMap.get(salesDatetime.format(MONTH_FORMAT)).sales_prediction_other__c != salesForcast.common_sales_others__c
                        || salesForecastMap.get(salesDatetime.format(MONTH_FORMAT)).expense_prediction_other__c != salesForcast.common_cost_others__c
                    ) {
                        unReflectedFlg = true;
                    }
                }
            }
        }

        // 売上実績取得
        List<PredictedValue__c> salesPerformanceList = [
            SELECT uriageNengetsu__c
                 , common_sales_stacked__c
                 , common_sales_proper_stacked__c
                 , common_sales_outsourcing_stacked__c
                 , common_sales_others__c
                 , common_cost_stacked__c
                 , common_cost_proper_stacked__c
                 , common_cost_proper_overtime__c
                 , common_cost_proper_expense__c
                 , common_cost_outsourcing_stacked__c
                 , common_cost_outsourcing_expense__c
                 , common_cost_others__c
                 , common_revenue_stacked__c
                 , common_revenue_proper_stacked__c
                 , common_revenue_outsourcing_stacked__c
                 , common_revenue_others__c
              FROM PredictedValue__c
             WHERE opportunity_ref__r.Id = :controller.getId() 
               AND type__c = :TYPE_PERFORMANCE
        ];

        // 売上実績リストをMapに詰め替える
        for(PredictedValue__c salesPerformance : salesPerformanceList) {
            // Date型にはformat関数がないため、Datetime型に変換してフォーマットする
            Date salesDate = salesPerformance.uriageNengetsu__c;
            Datetime salesDatetime = Datetime.newInstance(salesDate.year(), salesDate.month(), salesDate.day());

            salesPerformanceMap.put(salesDatetime.format(MONTH_FORMAT), salesPerformance);
        }

        // 売上実績未登録時は売上予測の対応月分の枠だけ表示する
        for (String salesForecastKey : salesForecastMap.keySet()) {
            if (!salesPerformanceMap.containsKey(salesForecastKey)) {
                PredictedValue__c salesPerformance = new PredictedValue__c();
                salesPerformance.uriageNengetsu__c = Date.valueOf(salesForecastKey.replaceAll('/', '-') + '-01');
                salesPerformanceMap.put(salesForecastKey, salesPerformance);
            }
        }

        System.debug('◆◆◆◆SalesAnalyticsController:END');       
    }
    
    public Pagereference save() {
        System.debug('◆◆◆◆save:START');
        
        // 商談オブジェクト取得
        List<Opportunity> opportunities = [
            SELECT Id
                 , Name
                 , Account.Name
                 , Projects_name__r.Name
                 , contract_style__c
                 , branch__c
              FROM Opportunity
             WHERE Id = :opportunityId
             LIMIT 1
        ];
        Opportunity opportunity = opportunities[0];
        
        
        // 予測登録
        for (String key : salesForecastMap.keySet()) {
            PredictedValue__c salesForecast = salesForecastMap.get(key);
            
            // 売上分析オブジェクトのID取得
            List<PredictedValue__c> salesForecastList = [
                SELECT Id
                  FROM PredictedValue__c
                 WHERE opportunity_ref__c = :opportunity.Id
                   AND uriageNengetsu__c = :salesForecast.uriageNengetsu__c
                   AND type__c = :TYPE_FORECAST
                 LIMIT 1
            ];
            
            // 予測レコード作成
            if (salesForecastList.size() > 0) {
                salesForecast.Id = salesForecastList[0].Id;
            }
            salesForecast.Name = '(' + opportunity.Account.Name + ')' + opportunity.Projects_name__r.Name
;
            salesForecast.type__c = TYPE_FORECAST;
            salesForecast.contract_style__c = opportunity.contract_style__c;
            salesForecast.opportunity_ref__c = opportunity.Id;
            salesForecast.branch_ref__c = opportunity.branch__c;
            // TODO 詰め替え不要な作りにリファクタ
            // 詰め替え
            salesForecast.common_sales_proper_stacked__c = salesForecast.sales_prediction_proper_stacked__c;
            salesForecast.common_sales_outsourcing_stacked__c = salesForecast.sales_prediction_outsourcing_stacked__c;
            salesForecast.common_sales_others__c = salesForecast.sales_prediction_other__c;
            salesForecast.common_cost_proper_stacked__c = salesForecast.expense_prediction_proper_stacked__c;
            salesForecast.common_cost_outsourcing_stacked__c = salesForecast.expense_prediction_outsourcing_stacked__c;
            salesForecast.common_cost_others__c = salesForecast.expense_prediction_other__c;
            
            upsert salesForecast;
            
            // 各月の商談商品情報取得
            List<OpportunityLineItem> opportunityLineItemList = [
                SELECT id
                     , orderNo__c
                  FROM OpportunityLineItem
                 WHERE Opportunity.Id = :opportunity.Id
                   AND taioTsuki__c = :salesForecast.uriageNengetsu__c
            ];
            
            // 注文番号登録
            for (OpportunityLineItem opportunityLineItem : opportunityLineItemList) {
                opportunityLineItem.orderNo__c = salesForecast.orderNo__c;
                upsert opportunityLineItem;
            }
        }
                
        // 実績登録
        for (String key : salesPerformanceMap.keySet()) {
            PredictedValue__c salesPerformance = salesPerformanceMap.get(key);
            
            // 売上分析オブジェクトのID取得
            List<PredictedValue__c> salesPerformanceList = [
                SELECT Id
                  FROM PredictedValue__c
                 WHERE opportunity_ref__c = :opportunity.Id
                   AND uriageNengetsu__c = :salesPerformance.uriageNengetsu__c
                   AND type__c = :TYPE_PERFORMANCE
                 LIMIT 1
            ];
            
            // 実績レコード作成
            if (salesPerformanceList .size() > 0) {
                salesPerformance.Id = salesPerformanceList [0].Id;
            }
            salesPerformance.Name = '(' + opportunity.Account.Name + ')' + opportunity.Projects_name__r.Name
;
            salesPerformance.type__c = TYPE_PERFORMANCE;
            salesPerformance.contract_style__c = opportunity.contract_style__c;
            salesPerformance.opportunity_ref__c = opportunity.Id;
            salesPerformance.branch_ref__c = opportunity.branch__c;
            
            upsert salesPerformance;
        }
        
        System.debug('◆◆◆◆save:END');
        return Page.salesInput;
    }
}