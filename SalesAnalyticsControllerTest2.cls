@isTest
private class  SalesAnalyticsControllerTest2 {

    // 商談商品の最初のデータがプロパの場合
    static testMethod void viewProperTest () {
        System.debug('★★★表示テスト:テストスタート');

        // ---------テストスタート--------------
        Test.startTest();
        
        
        // ユーザデータ登録
        List<Profile> userprofile = [SELECT Id FROM Profile LIMIT 1];
        Profile user1 = userprofile[0];
        User user = new User(
            LastName='hamaguchi',
            FirstName='taro',
            Alias='濱口太郎',
            Email='t-hamaguchi@test.co.jp',
            Username='t-hamaguchi@test.co.jp',
            CommunityNickname='t-hamaguchi',
            ProfileId=String.valueOf(user1.Id),
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            EmailEncodingKey = 'ISO-2022-JP',
            LanguageLocaleKey = 'ja'
        );
        insert user;
        
        // 取引先作成
        Account account = new Account(Name='取引先名');
        insert account;

        
        //案件作成
        Projects__c project = new Projects__c(
            Name='案件名',
            Suppliers__c=account.Id
        );
        insert project;
        
        // 部門データ登録
        Branch__c branch = new Branch__c(
            Name='テスト部門',
            manager__c=user.Id
        );
        insert branch;
        
        // 商談データ登録
        Opportunity opportunity = new Opportunity(
            Name='商談Ａ',
            StageName='見積作成',
            CloseDate=system.today(),
            branch__c=branch.Id,
            Projects_name__c=project.Id
        );
        insert opportunity;

        
        // 商品データ登録
        Product2 productA = new Product2(Name = '社員Ａ', ProductCode = '01', isActive = true, branch__c = branch.Id);
        Product2 productB = new Product2(Name = '社員Ｂ', ProductCode = '01', isActive = true, branch__c = branch.Id);
        Product2 productC = new Product2(Name = '外注Ｃ', ProductCode = '02', isActive = true, branch__c = branch.Id);
        Product2 productD = new Product2(Name = 'その他Ｄ', ProductCode = '99', isActive = true, branch__c = branch.Id);
        insert productA;
        insert productB;
        insert productC;
        insert productD;

        // 価格表データ登録
        ID pbId = Test.getStandardPricebookId();
        PricebookEntry pbEntryA = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productA.Id, UnitPrice = 500000, IsActive = true);
        PricebookEntry pbEntryB = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productB.Id, UnitPrice = 550000, IsActive = true);
        PricebookEntry pbEntryC = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productC.Id, UnitPrice = 400000, IsActive = true);
        PricebookEntry pbEntryD = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productD.Id, UnitPrice = 100000, IsActive = true);
        insert pbEntryA;
        insert pbEntryB;
        insert pbEntryC;
        insert pbEntryD;
                
        // 商談商品データ登録
        OpportunityLineItem opportunityLineItemA = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-07-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemB = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemC = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-09-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemD = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-07-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryC.Id);
        OpportunityLineItem opportunityLineItemE = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryC.Id);
        OpportunityLineItem opportunityLineItemF = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-09-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryB.Id);
        OpportunityLineItem opportunityLineItemG = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 0, Quantity = 1, PricebookEntryId = pbEntryD.Id);
        insert opportunityLineItemA;
        insert opportunityLineItemB;
        insert opportunityLineItemC;
        insert opportunityLineItemD;
        insert opportunityLineItemE;
        insert opportunityLineItemF;
        insert opportunityLineItemG;

        // 売上分析データ登録
        PredictedValue__c salesPerformanceA = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '実績', uriageNengetsu__c = Date.valueOf('2016-07-01'), branch_ref__c = branch.Id);
        PredictedValue__c salesPerformanceB = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '実績', uriageNengetsu__c = Date.valueOf('2016-08-01'), branch_ref__c = branch.Id);
        PredictedValue__c salesPerformanceC = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '実績', uriageNengetsu__c = Date.valueOf('2016-09-01'), branch_ref__c = branch.Id);
        insert salesPerformanceA;
        insert salesPerformanceB;
        insert salesPerformanceC;

        // 標準コントローラを生成
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);

        // コントローラー作成
        SalesAnalyticsController salesAnalyticsController = new SalesAnalyticsController(stdController);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_proper_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_outsourcing_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_expense_prediction_stacked__c , 900000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_proper_stacked__c , 500000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_outsourcing_stacked__c , 400000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_stacked__c , 300000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_proper_stacked__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_outsourcing_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_other__c , 0);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_proper_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_outsourcing_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_expense_prediction_stacked__c , 1000000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_proper_stacked__c , 500000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_outsourcing_stacked__c , 400000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_other__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_proper_stacked__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_outsourcing_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_other__c , -100000);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_proper_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_expense_prediction_stacked__c , 1050000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_proper_stacked__c , 1050000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_stacked__c , 150000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_proper_stacked__c , 150000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_other__c , 0);

        Test.stopTest();
        // ---------テスト終了------------------
        System.debug('★★★表示テスト：END★★★');
        
    }

    // 商談商品の最初のデータが外注の場合
    static testMethod void viewOutsourcingTest () {
        System.debug('★★★表示テスト:テストスタート');

        // ---------テストスタート--------------
        Test.startTest();   
         
        // ユーザデータ登録
        List<Profile> userprofile = [SELECT Id FROM Profile LIMIT 1];
        Profile user1 = userprofile[0];
        User user = new User(
            LastName='hamaguchi',
            FirstName='taro',
            Alias='濱口太郎',
            Email='t-hamaguchi@test.co.jp',
            Username='t-hamaguchi@test.co.jp',
            CommunityNickname='t-hamaguchi',
            ProfileId=String.valueOf(user1.Id),
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            EmailEncodingKey = 'ISO-2022-JP',
            LanguageLocaleKey = 'ja'
        );
        insert user;

                
        // 取引先作成
        Account account = new Account(Name='取引先名');
        insert account;

        
        //案件作成
        Projects__c project = new Projects__c(
            Name='案件名',
            Suppliers__c=account.Id
        );
        insert project;
        
        // 部門データ登録
        Branch__c branch = new Branch__c(
            Name='テスト部門',
            manager__c=user.Id
        );
        insert branch;
        
        // 商談データ登録
        Opportunity opportunity = new Opportunity(
            Name='商談Ａ',
            StageName='見積作成',
            CloseDate=system.today(),
            branch__c=branch.Id,
            Projects_name__c=project.Id
        );
        insert opportunity;

        
        // 商品データ登録
        Product2 productA = new Product2(Name = '社員Ａ', ProductCode = '01', isActive = true, branch__c=branch.Id);
        Product2 productB = new Product2(Name = '社員Ｂ', ProductCode = '01', isActive = true, branch__c=branch.Id);
        Product2 productC = new Product2(Name = '外注Ｃ', ProductCode = '02', isActive = true, branch__c=branch.Id);
        Product2 productD = new Product2(Name = 'その他Ｄ', ProductCode = '99', isActive = true, branch__c=branch.Id);
        insert productA;
        insert productB;
        insert productC;
        insert productD;

        // 価格表データ登録
        ID pbId = Test.getStandardPricebookId();
        PricebookEntry pbEntryA = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productA.Id, UnitPrice = 500000, IsActive = true);
        PricebookEntry pbEntryB = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productB.Id, UnitPrice = 550000, IsActive = true);
        PricebookEntry pbEntryC = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productC.Id, UnitPrice = 400000, IsActive = true);
        PricebookEntry pbEntryD = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productD.Id, UnitPrice = 100000, IsActive = true);
        insert pbEntryA;
        insert pbEntryB;
        insert pbEntryC;
        insert pbEntryD;
                
        // 商談商品データ登録
        OpportunityLineItem opportunityLineItemA = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-07-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryC.Id);
        OpportunityLineItem opportunityLineItemB = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryC.Id);
        OpportunityLineItem opportunityLineItemC = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-09-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryB.Id);
        OpportunityLineItem opportunityLineItemD = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-07-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemE = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemF = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-09-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemG = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 0, Quantity = 1, PricebookEntryId = pbEntryD.Id);
        insert opportunityLineItemA;
        insert opportunityLineItemB;
        insert opportunityLineItemC;
        insert opportunityLineItemD;
        insert opportunityLineItemE;
        insert opportunityLineItemF;
        insert opportunityLineItemG;
        
        // 売上分析データ登録
        PredictedValue__c salesForcaxtA = new PredictedValue__c(opportunity_ref__c = opportunity.Id, uriageNengetsu__c = Date.valueOf('2016-07-01'), type__c = '予測', branch_ref__c = branch.Id);
        insert salesForcaxtA;

        // 標準コントローラを生成
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);

        // コントローラー作成
        SalesAnalyticsController salesAnalyticsController = new SalesAnalyticsController(stdController);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_proper_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_outsourcing_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_expense_prediction_stacked__c , 900000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_proper_stacked__c , 500000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_outsourcing_stacked__c , 400000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_stacked__c , 300000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_proper_stacked__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_outsourcing_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_other__c , 0);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_proper_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_outsourcing_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_expense_prediction_stacked__c , 1000000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_proper_stacked__c , 500000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_outsourcing_stacked__c , 400000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_other__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_proper_stacked__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_outsourcing_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_other__c , -100000);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_proper_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_expense_prediction_stacked__c , 1050000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_proper_stacked__c , 1050000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_stacked__c , 150000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_proper_stacked__c , 150000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_other__c , 0);

        Test.stopTest();
        // ---------テスト終了------------------
        System.debug('★★★表示テスト：END★★★');
        
    }

    // 商談商品の最初のデータがその他の場合
    static testMethod void viewOthersTest () {
        System.debug('★★★表示テスト:テストスタート');

        // ---------テストスタート--------------
        Test.startTest();   
        
        // ユーザデータ登録
        List<Profile> userprofile = [SELECT Id FROM Profile LIMIT 1];
        Profile user1 = userprofile[0];
        User user = new User(
            LastName='hamaguchi',
            FirstName='taro',
            Alias='濱口太郎',
            Email='t-hamaguchi@test.co.jp',
            Username='t-hamaguchi@test.co.jp',
            CommunityNickname='t-hamaguchi',
            ProfileId=String.valueOf(user1.Id),
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            EmailEncodingKey = 'ISO-2022-JP',
            LanguageLocaleKey = 'ja'
        );
        insert user;

        
        // 取引先作成
        Account account = new Account(Name='取引先名');
        insert account;

        
        //案件作成
        Projects__c project = new Projects__c(
            Name='案件名',
            Suppliers__c=account.Id
        );
        insert project;
        
        // 部門データ登録
        Branch__c branch = new Branch__c(
            Name='テスト部門',
            manager__c=user.Id
        );
        insert branch;
        
        // 商談データ登録
        Opportunity opportunity = new Opportunity(
            Name='商談Ａ',
            StageName='見積作成',
            CloseDate=system.today(),
            branch__c=branch.Id,
            Projects_name__c=project.Id
        );
        insert opportunity;

        
        // 商品データ登録
        Product2 productA = new Product2(Name = '社員Ａ', ProductCode = '01', isActive = true, branch__c=branch.Id);
        Product2 productB = new Product2(Name = '社員Ｂ', ProductCode = '01', isActive = true, branch__c=branch.Id);
        Product2 productC = new Product2(Name = '外注Ｃ', ProductCode = '02', isActive = true, branch__c=branch.Id);
        Product2 productD = new Product2(Name = 'その他Ｄ', ProductCode = '99', isActive = true, branch__c=branch.Id);
        insert productA;
        insert productB;
        insert productC;
        insert productD;

        // 価格表データ登録
        ID pbId = Test.getStandardPricebookId();
        PricebookEntry pbEntryA = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productA.Id, UnitPrice = 500000, IsActive = true);
        PricebookEntry pbEntryB = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productB.Id, UnitPrice = 550000, IsActive = true);
        PricebookEntry pbEntryC = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productC.Id, UnitPrice = 400000, IsActive = true);
        PricebookEntry pbEntryD = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productD.Id, UnitPrice = 100000, IsActive = true);
        insert pbEntryA;
        insert pbEntryB;
        insert pbEntryC;
        insert pbEntryD;
                
        // 商談商品データ登録
        OpportunityLineItem opportunityLineItemA = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 0, Quantity = 1, PricebookEntryId = pbEntryD.Id);
        OpportunityLineItem opportunityLineItemB = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-07-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemC = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemD = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-09-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemE = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-07-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryC.Id);
        OpportunityLineItem opportunityLineItemF = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-08-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryC.Id);
        OpportunityLineItem opportunityLineItemG = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate =  Date.valueOf('2016-09-01'), TotalPrice = 600000, Quantity = 1, PricebookEntryId = pbEntryB.Id);
        insert opportunityLineItemA;
        insert opportunityLineItemB;
        insert opportunityLineItemC;
        insert opportunityLineItemD;
        insert opportunityLineItemE;
        insert opportunityLineItemF;
        insert opportunityLineItemG;

        // 売上分析データ登録
        PredictedValue__c salesForcaxtA = new PredictedValue__c(opportunity_ref__c = opportunity.Id, uriageNengetsu__c = Date.valueOf('2016-07-01'), type__c = '予測', branch_ref__c = branch.Id);
        PredictedValue__c salesForcaxtB = new PredictedValue__c(opportunity_ref__c = opportunity.Id, uriageNengetsu__c = Date.valueOf('2016-08-01'), type__c = '予測', branch_ref__c = branch.Id);
        PredictedValue__c salesForcaxtC = new PredictedValue__c(opportunity_ref__c = opportunity.Id, uriageNengetsu__c = Date.valueOf('2016-09-01'), type__c = '予測', branch_ref__c = branch.Id);
        insert salesForcaxtA;
        insert salesForcaxtB;
        insert salesForcaxtC;

        // 標準コントローラを生成
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);

        // コントローラー作成
        SalesAnalyticsController salesAnalyticsController = new SalesAnalyticsController(stdController);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_proper_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_outsourcing_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_expense_prediction_stacked__c , 900000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_proper_stacked__c , 500000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_outsourcing_stacked__c , 400000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').expense_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_stacked__c , 300000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_proper_stacked__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_outsourcing_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/07').v_revenue_prediction_other__c , 0);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_proper_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_outsourcing_stacked__c , 600000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_expense_prediction_stacked__c , 1000000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_proper_stacked__c , 500000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_outsourcing_stacked__c , 400000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').expense_prediction_other__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_proper_stacked__c , 100000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_outsourcing_stacked__c , 200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/08').v_revenue_prediction_other__c , -100000);
        
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_sales_prediction_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_proper_stacked__c , 1200000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').sales_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_expense_prediction_stacked__c , 1050000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_proper_stacked__c , 1050000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').expense_prediction_other__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_stacked__c , 150000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_proper_stacked__c , 150000);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_outsourcing_stacked__c , 0);
        System.AssertEquals(salesAnalyticsController.salesForecastMap.get('2016/09').v_revenue_prediction_other__c , 0);

        Test.stopTest();
        // ---------テスト終了------------------
        System.debug('★★★表示テスト：END★★★');
        
    }

    // 明細作成
    static testMethod void saveTest () {
        System.debug('★★★明細作成テスト:テストスタート');

        // ---------テストスタート--------------
        Test.startTest();   
        
        // ユーザデータ登録
        List<Profile> userprofile = [SELECT Id FROM Profile LIMIT 1];
        Profile user1 = userprofile[0];
        User user = new User(
            LastName='hamaguchi',
            FirstName='taro',
            Alias='濱口太郎',
            Email='t-hamaguchi@test.co.jp',
            Username='t-hamaguchi@test.co.jp',
            CommunityNickname='t-hamaguchi',
            ProfileId=String.valueOf(user1.Id),
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            EmailEncodingKey = 'ISO-2022-JP',
            LanguageLocaleKey = 'ja'
        );
        insert user;

        
        // 取引先作成
        Account account = new Account(Name='取引先名');
        insert account;

        
        //案件作成
        Projects__c project = new Projects__c(
            Name='案件名',
            Suppliers__c=account.Id
        );
        insert project;
        
        // 部門データ登録
        Branch__c branch = new Branch__c(
            Name='テスト部門',
            manager__c=user.Id
        );
        insert branch;
        
        // 商談データ登録
        Opportunity opportunity = new Opportunity(
            Name='商談Ａ',
            StageName='見積作成',
            CloseDate=system.today(),
            branch__c=branch.Id,
            Projects_name__c=project.Id
        );
        insert opportunity;

        // 商品データ登録
        Product2 productA = new Product2(Name = '社員Ａ', ProductCode = '01', isActive = true, branch__c=branch.Id);
        Product2 productB = new Product2(Name = '社員Ｂ', ProductCode = '01', isActive = true, branch__c=branch.Id);
        Product2 productC = new Product2(Name = '外注Ｃ', ProductCode = '02', isActive = true, branch__c=branch.Id);
        insert productA;
        insert productB;
        insert productC;

        // 価格表データ登録
        ID pbId = Test.getStandardPricebookId();
        PricebookEntry pbEntryA = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productA.Id, UnitPrice = 500000, IsActive = true);
        PricebookEntry pbEntryB = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productB.Id, UnitPrice = 550000, IsActive = true);
        PricebookEntry pbEntryC = new PricebookEntry(Pricebook2Id = pbId, Product2Id = productC.Id, UnitPrice = 400000, IsActive = true);
        insert pbEntryA;
        insert pbEntryB;
        insert pbEntryC;

        // 商談商品登録
        OpportunityLineItem opportunityLineItemA = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate = Date.valueOf('2016-07-01'), orderNo__c = '0000-0001', Quantity = 1, TotalPrice = 100, PricebookEntryId = pbEntryA.Id);
        OpportunityLineItem opportunityLineItemB = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate = Date.valueOf('2016-08-01'), orderNo__c = '0000-0002', Quantity = 1, TotalPrice = 100, PricebookEntryId = pbEntryB.Id);
        OpportunityLineItem opportunityLineItemC = new OpportunityLineItem(OpportunityId = opportunity.Id, ServiceDate = Date.valueOf('2016-09-01'), orderNo__c = '0000-0003', Quantity = 1, TotalPrice = 100, PricebookEntryId = pbEntryC.Id);
        insert opportunityLineItemA;
        insert opportunityLineItemB;
        insert opportunityLineItemC;

        // 標準コントローラを生成
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);

        // コントローラー作成
        SalesAnalyticsController salesAnalyticsController = new SalesAnalyticsController(stdController);

        // 売上分析データ登録
        PredictedValue__c salesForecastA = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '予測', uriageNengetsu__c = Date.valueOf('2016-07-01'), common_sales_proper_stacked__c = 100, branch_ref__c=branch.Id);
        PredictedValue__c salesForecastB = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '予測', uriageNengetsu__c = Date.valueOf('2016-07-01'), sales_prediction_proper_stacked__c = 200, branch_ref__c=branch.Id);
        PredictedValue__c salesForecastC = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '予測', uriageNengetsu__c = Date.valueOf('2016-08-01'));
        PredictedValue__c salesForecastD = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '予測', uriageNengetsu__c = Date.valueOf('2016-09-01'));
        insert salesForecastA;
        Map<String, PredictedValue__c> salesForecastMap = new Map<String, PredictedValue__c>();
        salesForecastMap.put('2016/07', salesForecastB);
        salesForecastMap.put('2016/08', salesForecastC);
        salesForecastMap.put('2016/09', salesForecastD);

        PredictedValue__c salesPerformanceA = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '実績', uriageNengetsu__c = Date.valueOf('2016-07-01'), common_sales_proper_stacked__c = 100, branch_ref__c=branch.Id);
        PredictedValue__c salesPerformanceB = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '実績', uriageNengetsu__c = Date.valueOf('2016-07-01'), common_sales_proper_stacked__c = 200, branch_ref__c=branch.Id);
        PredictedValue__c salesPerformanceC = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '実績', uriageNengetsu__c = Date.valueOf('2016-08-01'));
        PredictedValue__c salesPerformanceD = new PredictedValue__c(opportunity_ref__c = opportunity.Id, type__c = '実績', uriageNengetsu__c = Date.valueOf('2016-09-01'));
        insert salesPerformanceA;
        Map<String, PredictedValue__c> salesPerformanceMap = new Map<String, PredictedValue__c>();
        salesPerformanceMap.put('2016/07', salesPerformanceB);
        salesPerformanceMap.put('2016/08', salesPerformanceC);
        salesPerformanceMap.put('2016/09', salesPerformanceD);
        
        salesAnalyticsController.salesForecastMap = salesForecastMap;
        salesAnalyticsController.salesPerformanceMap = salesPerformanceMap;
        salesAnalyticsController.opportunityId = opportunity.Id;
        salesAnalyticsController.save();

        // 売上予測取得
        List<PredictedValue__c> salesForecastList = [
            SELECT common_sales_proper_stacked__c
              FROM PredictedValue__c
             WHERE opportunity_ref__r.Id = :opportunity.Id
               AND uriageNengetsu__c = :Date.valueOf('2016-07-01')
               AND type__c = '予測'
        ];
        // 売上実績取得
        List<PredictedValue__c> salesPerformanceList = [
            SELECT common_sales_proper_stacked__c
              FROM PredictedValue__c
             WHERE opportunity_ref__r.Id = :opportunity.Id
               AND uriageNengetsu__c = :Date.valueOf('2016-07-01')
               AND type__c = '実績'
        ];

        System.AssertEquals(salesForecastList[0].common_sales_proper_stacked__c , 200);
        System.AssertEquals(salesPerformanceList[0].common_sales_proper_stacked__c , 200);

        Test.stopTest();
        // ---------テスト終了------------------
        System.debug('★★★明細作成テスト：END★★★');
        
    }
}