#!/usr/bin/env bash
## combine and clean logs ready for gource
## https://github.com/acaudwell/Gource/wiki/Visualizing-Multiple-Repositories

set -o errexit # Abort if any command fails
me=$(basename "$0")

help_message="\
Usage:
  ${me} [--no-clone] [--verbose]
  ${me} --help
Arguments:
  -n, --no-clone    Does not clone or update the repositories before processing.
  -h, --help        Displays this help screen.
  -v, --verbose     Increase verbosity. Useful for debugging."

parse_args() {
  while :; do
    if [[ $1 = "-h" || $1 = "--help" ]]; then
      echo "${help_message}"
      return 0
    elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
      verbose=true
      shift
    elif [[ $1 = "-n" || $1 = "--no-clone" ]]; then
      no_clone=true
      shift
    else
      break
    fi
  done
}

# Echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
    if [ "${verbose}" = true ]; then
        set -o xtrace
        set +o verbose
    fi
}

clone_repositories() {
  repos=(
    "PayEx/Acquiring.Api" \
    "PayEx/BIP.Acquiring.Api.Swagger" \
    "PayEx/BIP.Acquiring.ExcelReportDaemon" \
    "PayEx/BIP.Acquiring.ImportDaemon" \
    "PayEx/BIP.Acquiring.TestDataGenerator" \
    "PayEx/BIP.Airflow" \
    "PayEx/BIP.Airflow.DAGs" \
    "PayEx/BIP.Airflow.Database" \
    "PayEx/BIP.Airflow.Task.DockerJavaDemo" \
    "PayEx/BIP.Filebeat" \
    "PayEx/BIP.Loadbalancer" \
    "PayEx/BIP.Logstash" \
    "PayEx/BIP.MongoDB" \
    "PayEx/BIP.Psp.PaymentAnalyticsPipelineConsumer" \
    "PayEx/BIP.RabbitMQ" \
    "PayEx/Commerce.Authentications" \
    "PayEx/dummyShop2.0" \
    "PayEx/ELK.Filebeat.Config" \
    "PayEx/ELK.Heartbeat.Config" \
    "PayEx/ELK.Metricbeat.Config" \
    "PayEx/Monitoring.ObservationSender" \
    "PayEx/ndctetris-server" \
    "PayEx/PayEx.Checkout.Demo" \
    "PayEx/PayEx.Checkout.TestSite" \
    "PayEx/PayEx.ELK.Logstash.Config" \
    "PayEx/PayEx.Psp.Admin" \
    "PayEx/PayEx.Psp.Admin.AcceptanceTests" \
    "PayEx/PayEx.Psp.AdminUI" \
    "PayEx/PayEx.Psp.AdminUI.BaseInstrument" \
    "PayEx/PayEx.Psp.AdminUI.CarPay" \
    "PayEx/PayEx.Psp.AdminUI.Corporations" \
    "PayEx/PayEx.Psp.AdminUI.CreditAccount" \
    "PayEx/PayEx.Psp.AdminUI.CreditCard" \
    "PayEx/PayEx.Psp.AdminUI.CreditCard.Container" \
    "PayEx/PayEx.Psp.AdminUI.CreditCard.Legacy" \
    "PayEx/PayEx.Psp.AdminUI.Dashboard" \
    "PayEx/PayEx.Psp.AdminUI.DirectDebit.Legacy" \
    "PayEx/PayEx.Psp.AdminUI.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.AdminUI.History" \
    "PayEx/PayEx.Psp.AdminUI.Invoice" \
    "PayEx/PayEx.Psp.AdminUI.Layout" \
    "PayEx/PayEx.Psp.AdminUI.Login" \
    "PayEx/PayEx.Psp.AdminUI.Merchants" \
    "PayEx/PayEx.Psp.AdminUI.MobilePay" \
    "PayEx/PayEx.Psp.AdminUI.MobilePay.Legacy" \
    "PayEx/Payex.Psp.AdminUI.Owner" \
    "PayEx/PayEx.Psp.AdminUI.Search" \
    "PayEx/PayEx.Psp.AdminUI.Search.AcceptanceTests" \
    "PayEx/PayEx.Psp.AdminUI.Swish" \
    "PayEx/PayEx.Psp.AdminUI.Swish.Legacy" \
    "PayEx/PayEx.Psp.AdminUI.Users" \
    "PayEx/PayEx.Psp.AdminUI.ViaBill.Legacy" \
    "PayEx/PayEx.Psp.AdminUI.Vipps" \
    "PayEx/PayEx.Psp.AdminUI.Vipps.Frontend.AcceptanceTests.Legacy" \
    "PayEx/PayEx.Psp.AdminUI.Vipps.Legacy" \
    "PayEx/PayEx.Psp.AdminUIv2" \
    "PayEx/PayEx.Psp.ApiKeepAlive" \
    "PayEx/PayEx.Psp.ApiMock" \
    "PayEx/PayEx.Psp.ApiTools" \
    "PayEx/PayEx.Psp.BuildTools" \
    "PayEx/PayEx.Psp.CarPay" \
    "PayEx/PayEx.Psp.CarPayContracts" \
    "PayEx/PayEx.Psp.CarPayContractsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.CarPayPaymentsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.CarPayPaymentsUI.HostedView" \
    "PayEx/PayEx.Psp.Certificate.DanskeBank" \
    "PayEx/PayEx.Psp.Checkout" \
    "PayEx/PayEx.Psp.Consumer.AcceptanceTestsUtils_DEPRECATED" \
    "PayEx/PayEx.Psp.Consumers" \
    "PayEx/PayEx.Psp.Consumers.AcceptanceTests" \
    "PayEx/PayEx.Psp.Consumers.TestSites" \
    "PayEx/PayEx.Psp.ConsumersUI" \
    "PayEx/PayEx.Psp.ConsumersUI.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.Contract.Template" \
    "PayEx/PayEx.Psp.Contracts" \
    "PayEx/PayEx.Psp.Contracts.AcceptanceTests" \
    "PayEx/PayEx.Psp.CreditAccount.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.CreditAccountPaymentsUi.HostedView" \
    "PayEx/PayEx.Psp.CreditCard" \
    "PayEx/PayEx.Psp.CreditCard.CardDataMigrator" \
    "PayEx/PayEx.Psp.CreditCard.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.CreditCardConfinedPaymentsApi" \
    "PayEx/PayEx.Psp.CreditCardConfinedPaymentsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.CreditCardContracts" \
    "PayEx/PayEx.Psp.CreditCardContractsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.CreditCardFakeService" \
    "PayEx/PayEx.Psp.CreditCardPaymentsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.CreditCardPaymentsUI" \
    "PayEx/PayEx.Psp.CreditCardPaymentsUi.HostedView" \
    "PayEx/PayEx.Psp.Customer.AcceptanceTests" \
    "PayEx/PayEx.Psp.Customers" \
    "PayEx/PayEx.Psp.Daemon.Callback" \
    "PayEx/PayEx.Psp.Daemon.DocumentStore" \
    "PayEx/PayEx.Psp.Daemon.Srm.CarPayContract" \
    "PayEx/PayEx.Psp.Daemon.Srm.CreditCardContract" \
    "PayEx/PayEx.Psp.Daemon.Srm.InvoiceContract" \
    "PayEx/PayEx.Psp.Daemon.Srm.Merchant" \
    "PayEx/PayEx.Psp.Daemon.Srm.MerchantGroup" \
    "PayEx/PayEx.Psp.Daemon.Srm.MobilePayContract" \
    "PayEx/PayEx.Psp.Daemon.Srm.SwishContract" \
    "PayEx/PayEx.Psp.Daemon.Srm.ViaBillContract" \
    "PayEx/PayEx.Psp.Daemon.Srm.VippsContract" \
    "PayEx/PayEx.Psp.DemoShop" \
    "PayEx/PayEx.Psp.Demoshop.Janitor" \
    "PayEx/PayEx.Psp.DeviceIdentification" \
    "PayEx/PayEx.Psp.DirectDebit" \
    "PayEx/PayEx.Psp.DirectDebit.ExternalBinaries" \
    "PayEx/PayEx.Psp.DirectDebit.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.DirectDebit.SwedbankCryptoApi" \
    "PayEx/PayEx.Psp.DirectDebitContracts" \
    "PayEx/PayEx.Psp.DirectDebitContractsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.DirectDebitFakeService" \
    "PayEx/PayEx.Psp.DirectDebitPaymentsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.DirectDebitPaymentsUI" \
    "PayEx/PayEx.Psp.DirectDebitTestUI" \
    "PayEx/PayEx.Psp.DocumentStore" \
    "PayEx/PayEx.Psp.DocumentStore.Resend" \
    "PayEx/PayEx.Psp.EcomPayments" \
    "PayEx/PayEx.Psp.Encryption" \
    "PayEx/PayEx.Psp.ExceptionHandling" \
    "PayEx/PayEx.Psp.Exceptions" \
    "PayEx/PayEx.Psp.ExternalResourceHost" \
    "PayEx/PayEx.Psp.FakeServices" \
    "PayEx/PayEx.Psp.Frontend.AcceptanceTestBase" \
    "PayEx/PayEx.Psp.Health" \
    "PayEx/PayEx.Psp.InstrumentPayments" \
    "PayEx/PayEx.Psp.InstrumentPaymentsApi" \
    "PayEx/PayEx.Psp.IntegrationTests" \
    "PayEx/PayEx.Psp.Invoice" \
    "PayEx/PayEx.Psp.Invoice.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.InvoiceContracts" \
    "PayEx/PayEx.Psp.InvoiceContractsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.InvoiceFakeService" \
    "PayEx/PayEx.Psp.InvoicePaymentApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.InvoicePaymentsUI" \
    "PayEx/PayEx.Psp.InvoicePaymentsUi.HostedView" \
    "PayEx/PayEx.Psp.IsoCodes" \
    "PayEx/PayEx.Psp.Kibana" \
    "PayEx/PayEx.Psp.Languages-DEPRECATED-" \
    "PayEx/PayEx.Psp.LoadTests" \
    "PayEx/PayEx.Psp.LoadTests.Artillery" \
    "PayEx/Payex.Psp.LoadTests.Authorization" \
    "PayEx/Payex.Psp.LoadTests.Consumers" \
    "PayEx/PayEx.Psp.Logging" \
    "PayEx/PayEx.Psp.Logging.Sla" \
    "PayEx/PayEx.Psp.Login" \
    "PayEx/PayEx.Psp.Messaging" \
    "PayEx/PayEx.Psp.MnoBilling" \
    "PayEx/PayEx.Psp.MnoBillingContracts" \
    "PayEx/PayEx.Psp.MobilePay" \
    "PayEx/PayEx.Psp.MobilePay.ContractsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.MobilePay.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.MobilePay.Frontend.AcceptanceTests.Legacy" \
    "PayEx/PayEx.Psp.MobilePay.PaymentsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.MobilePay.Proxy" \
    "PayEx/PayEx.Psp.MobilePayConfinedService" \
    "PayEx/PayEx.Psp.MobilePayContracts" \
    "PayEx/PayEx.Psp.MobilePayFakeService" \
    "PayEx/PayEx.Psp.MobilePayPaymentsUI" \
    "PayEx/PayEx.Psp.MobilePayPaymentsUi.HostedView" \
    "PayEx/PayEx.Psp.Onboarding.Merchants.CLITool" \
    "PayEx/PayEx.Psp.Payment.Behavior.RankingDemo" \
    "PayEx/PayEx.Psp.Payment.Behavior.RankingMediator" \
    "PayEx/PayEx.Psp.Payment.Template" \
    "PayEx/PayEx.Psp.PaymentControl" \
    "PayEx/PayEx.Psp.PaymentEventHandlers" \
    "PayEx/PayEx.Psp.PaymentLinks" \
    "PayEx/PayEx.Psp.PaymentMenu.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.PaymentMenuUI" \
    "PayEx/PayEx.Psp.PaymentOrders" \
    "PayEx/PayEx.Psp.PaymentOrders.AcceptanceTests" \
    "PayEx/PayEx.Psp.PaymentPages.TestSite" \
    "PayEx/PayEx.Psp.Payments" \
    "PayEx/PayEx.Psp.Pops.AgreementMigrator" \
    "PayEx/PayEx.Psp.PxCProxy" \
    "PayEx/PayEx.Psp.RabbitMQ.Client" \
    "PayEx/PayEx.Psp.Redis" \
    "PayEx/PayEx.Psp.Reports" \
    "PayEx/PayEx.Psp.Reports.DocumentStoreService" \
    "PayEx/PayEx.Psp.ResourceContracts" \
    "PayEx/PayEx.Psp.Sdk.ControllerClientBase.Obsolete" \
    "PayEx/PayEx.Psp.Sdk.SystemInfo" \
    "PayEx/PayEx.Psp.Sdk.TestUtil" \
    "PayEx/PayEx.Psp.Search" \
    "PayEx/PayEx.Psp.Search.AcceptanceTests" \
    "PayEx/PayEx.Psp.Statistic" \
    "PayEx/PayEx.Psp.Surveillance" \
    "PayEx/PayEx.Psp.Swish" \
    "PayEx/PayEx.Psp.Swish.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.SwishContracts" \
    "PayEx/PayEx.Psp.SwishContracts.AcceptanceTests" \
    "PayEx/PayEx.Psp.SwishPaymentsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.SwishPaymentsUI" \
    "PayEx/PayEx.Psp.SwishPaymentsUI.HostedView" \
    "PayEx/PayEx.Psp.TdcReconciliations" \
    "PayEx/PayEx.Psp.Validation" \
    "PayEx/PayEx.Psp.ViaBill" \
    "PayEx/PayEx.Psp.ViaBill.Frontend.AcceptanceTest" \
    "PayEx/PayEx.Psp.ViaBillContracts" \
    "PayEx/PayEx.Psp.ViaBillContractsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.ViaBillFakeService" \
    "PayEx/PayEx.Psp.ViaBillPaymentsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.ViaBillPaymentsUI.HostedView" \
    "PayEx/PayEx.Psp.ViaBillTestUI" \
    "PayEx/PayEx.Psp.Vipps" \
    "PayEx/PayEx.Psp.Vipps.Frontend.AcceptanceTests" \
    "PayEx/PayEx.Psp.VippsContracts" \
    "PayEx/PayEx.Psp.VippsContractsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.VippsFakeService" \
    "PayEx/PayEx.Psp.VippsPaymentsApi.AcceptanceTests" \
    "PayEx/PayEx.Psp.VippsPaymentsUI" \
    "PayEx/PayEx.Psp.VippsPaymentsUi.HostedView" \
    "PayEx/PayEx.Psp.WebApi.Client" \
    "PayEx/PayEx.UILogger.Transmitter" \
    "PayEx/Psp.AdminUI.Trustly" \
    "PayEx/Psp.Analytics.DynamicPaymentMenu" \
    "PayEx/Psp.ArchivedLogImporter" \
    "PayEx/Psp.Authorizations" \
    "PayEx/Psp.Authorizations.Configuration" \
    "PayEx/Psp.Busybox" \
    "PayEx/Psp.CertificateManager" \
    "PayEx/Psp.CreditAccount.Contracts" \
    "PayEx/Psp.CreditAccount.Contracts.AcceptanceTests" \
    "PayEx/Psp.CreditAccount.FakeService" \
    "PayEx/Psp.CreditAccount.Payments" \
    "PayEx/Psp.CreditAccount.Payments.AcceptanceTests" \
    "PayEx/Psp.Creditcard.Monitoring" \
    "PayEx/Psp.CreditCardPaymentsUi.3DS2.HostedView" \
    "PayEx/Psp.Customers.Monitoring" \
    "PayEx/Psp.Docker.Dotnet" \
    "PayEx/Psp.DockerSwarmTestApi" \
    "PayEx/Psp.Elastic.Apm" \
    "PayEx/Psp.ElasticSearch.Templates" \
    "PayEx/Psp.Filebeat.Onprem" \
    "PayEx/Psp.Filebeat.PCI" \
    "PayEx/Psp.FluentD" \
    "PayEx/Psp.Health" \
    "PayEx/Psp.IngressController" \
    "PayEx/Psp.Kibana.Watchers" \
    "PayEx/Psp.Kubernetes" \
    "PayEx/Psp.Kubernetes.Dashboard" \
    "PayEx/Psp.Kubernetes.Monitor" \
    "PayEx/Psp.Kured" \
    "PayEx/Psp.Logstash.Onprem" \
    "PayEx/Psp.Merchant.Prototype" \
    "PayEx/Psp.Metricbeat" \
    "PayEx/Psp.MobilePay.FakeService" \
    "PayEx/Psp.MobilePay.Monitoring" \
    "PayEx/Psp.Monitoring" \
    "PayEx/Psp.Monitoring.EcomNotifier" \
    "PayEx/Psp.Monitoring.IncidentManagementUi" \
    "PayEx/Psp.MonitorService" \
    "PayEx/Psp.PaymentCallback.FakeService" \
    "PayEx/Psp.PaymentOrders.Monitoring" \
    "PayEx/Psp.Portainer" \
    "PayEx/Psp.Reports.Monitoring" \
    "PayEx/Psp.Status" \
    "PayEx/Psp.SwishPaymentsUi.POC.Blazor" \
    "PayEx/Psp.TelephonePrefixes" \
    "PayEx/Psp.Terraform" \
    "PayEx/Psp.TestShop" \
    "PayEx/Psp.Trustly.Contracts" \
    "PayEx/Psp.Trustly.Contracts.AcceptanceTests" \
    "PayEx/Psp.Trustly.Frontend.AcceptanceTest" \
    "PayEx/Psp.Trustly.Monitoring" \
    "PayEx/Psp.Trustly.Payments" \
    "PayEx/Psp.Trustly.Payments.AcceptanceTests" \
    "PayEx/Psp.TrustlyPaymentsUI" \
    "PayEx/Psp.Utilities" \
    "PayEx/WebPageAnalysis" \
    "SwedbankPay/developer.swedbankpay.com" \
    "SwedbankPay/design.swedbankpay.com" \
    "SwedbankPay/docker-build-with-cache-action" \
    "SwedbankPay/git-directory-deploy" \
    "SwedbankPay/html-proofer-unrendered-markdown" \
    "SwedbankPay/jekyll-plantuml-docker" \
    "SwedbankPay/kramdown-plantuml" \
    "SwedbankPay/search.developer.swedbankpay.com" \
    "SwedbankPay/searchyll" \
    "SwedbankPay/swedbank-pay-design-guide-jekyll-theme" \
    "SwedbankPay/swedbank-pay-episerver-checkout" \
    "SwedbankPay/swedbank-pay-episerver-checkout-demo" \
    "SwedbankPay/swedbank-pay-magento2-checkout" \
    "SwedbankPay/swedbank-pay-magento2-core" \
    "SwedbankPay/swedbank-pay-magento2-payments" \
    "SwedbankPay/swedbank-pay-postman" \
    "SwedbankPay/swedbank-pay-sdk-android" \
    "SwedbankPay/swedbank-pay-sdk-android-example-app" \
    "SwedbankPay/swedbank-pay-sdk-dotnet" \
    "SwedbankPay/swedbank-pay-sdk-dotnet-extensions" \
    "SwedbankPay/swedbank-pay-sdk-ios" \
    "SwedbankPay/swedbank-pay-sdk-ios-example-app" \
    "SwedbankPay/swedbank-pay-sdk-ios-podspecs" \
    "SwedbankPay/swedbank-pay-sdk-js" \
    "SwedbankPay/swedbank-pay-sdk-mobile-example-merchant" \
    "SwedbankPay/swedbank-pay-sdk-php" \
    "SwedbankPay/swedbank-pay-woocommerce-checkout" \
    "SwedbankPay/swedbank-pay-woocommerce-core" \
    "SwedbankPay/swedbank-pay-woocommerce-payments" \
  )

  rm -f combo.log
  mkdir -p tmp/{repos,avatars}
  for repo in "${repos[@]}"; do
    printf "Processing '%s' ... " "$repo"
    if [ ! -d "tmp/repos/$repo" ]; then
      printf "cloning ... "
      git clone "git@github.com:$repo.git" "tmp/repos/$repo" 2>/dev/null
      echo " cloned."
    elif git -C "tmp/repos/$repo" pull 2>/dev/null | grep -v "Already up to date."; then
      echo "error"
    else
      echo "already up to date."
    fi
    gource --output-custom-log repo.log "tmp/repos/$repo"
    sed -r "s#(.+)\|#\1|/$repo#" repo.log >>combo.log
  done

  # sort by date - mix in combined repos.
  rm -f repo.log
  cat combo.log | sort -n >x.log
  mv x.log combo.log
}

fix_usernames() {
  echo "Fixing usernames ..."

  # username mapping fix for incorrect user.name
  declare -A user_fix
  user_fix["kristgn"]="Kristian Nilsen"
  user_fix["ittyGitty"]="Ine Benedikte Målbakken"
  user_fix["oya"]="Øyvind Årset"
  user_fix["oarset"]="Øyvind Årset"
  user_fix["Oyvind Årset"]="Øyvind Årset"
  user_fix["Sigrid"]="Sigrid Bratsberg"
  user_fix["Hakon Tangen"]="Håkon Tangen"
  user_fix["GFU"]="Gudrun Furu"
  user_fix["vitterso"]="Benjamin Vittersø"
  user_fix["aniajohansen"]="Ania Johansen"
  user_fix["erikhusemoen"]="Erik Husemoen"
  user_fix["erik.husemoen@payex.com"]="Erik Husemoen"
  user_fix["Erik Husemoen erik.husemoen@payex.com"]="Erik Husemoen"
  user_fix["klavestad"]="Sindre Klavestad"
  user_fix["Xillians"]="S. Toftemo"
  user_fix["Syver"]="S. Toftemo"
  user_fix["Syver Toftemo"]="S. Toftemo"
  user_fix["rodvei"]="Kristoffer Rødvei"
  user_fix["Kristoffer Kofoed-Rodvei"]="Kristoffer Rødvei"
  user_fix["Kristoffer Kofoed Rødvei"]="Kristoffer Rødvei"
  user_fix["espenmarstein"]="Espen Marstein"
  user_fix["dependabot[bot]"]="Dependabot"
  user_fix["dependabot-preview[bot]"]="Dependabot"
  user_fix["trieutran91"]="Trieu Tran"
  user_fix["ingvildn"]="Ingvild Nerås"
  user_fix["bjornops"]="Bjørn Opstad"
  user_fix["m-lilja"]="Martina Lilja"
  user_fix["JonAnders"]="Jon Anders Amundsen"
  user_fix["mariannemagnussen"]="Marianne Magnussen"
  user_fix["Hakon"]="Håkon Mosvoll"
  user_fix["hakon"]="Håkon Mosvoll"
  user_fix["aystmark"]="Andreas Ystmark"
  user_fix["andreasystmark@gmail.com"]="Andreas Ystmark"
  user_fix["AlfMagnus Stalesen"]="Alf Magnus Stålesen"
  user_fix["alfmags"]="Alf Magnus Stålesen"
  user_fix["rebekkavaa"]="Rebekka Aadland"
  user_fix["Rebekka Valen Aadland"]="Rebekka Aadland"
  user_fix["Eddkus"]="Eddie Kusturica"
  user_fix["gsr"]="Geir Straume"
  user_fix["nullableint"]="Daniel Granerud"
  user_fix["NullableInt"]="Daniel Granerud"
  user_fix["Nullableint"]="Daniel Granerud"
  user_fix["Nullint"]="Daniel Granerud"
  user_fix["Clement"]="Clément Joye"
  user_fix["clement.joye"]="Clément Joye"
  user_fix["Clement Joye"]="Clément Joye"
  user_fix["muzukashiine"]="Atle Eriksen"
  user_fix["Trond.Aslaksen"]="Trond Aslaksen"
  user_fix["erikhallaraaker"]="Erik Hallaraaker"
  user_fix["forssenm"]="Mathias Forssén"
  user_fix["Mathias Forssen"]="Mathias Forssén"
  user_fix["marinafrydenb"]="Marina Frydenberg"
  user_fix["karsten"]="Karsten Strand"
  user_fix["Karsten Nikolai Strand"]="Karsten Strand"
  user_fix["arebra"]="Are Brandt"
  user_fix["ErikKarlkvist"]="Erik Karlkvist"
  user_fix["kimfjellbo"]="Kim Fjellbo"
  user_fix["oyvigri"]="Øyvind Grimstad"
  user_fix["Shahriar Siraj"]="Md Shahriar Siraj"
  user_fix["SveinungTorresdal"]="Sveinung Tørresdal"
  user_fix["Sindre"]="Sindre Furulund"
  user_fix["siifux"]="Sindre Furulund"
  user_fix["skagejohan"]="Skage Spjelkavik"
  user_fix["okr"]="Øyvind Kristiansen"
  user_fix["joakimmag"]="Joakim Magnussen"
  user_fix["FSvnsn"]="Fredrik Nyseth Svendsen"
  user_fix["joelham"]="Johar Elhamoumi"
  user_fix["Joelham"]="Johar Elhamoumi"
  user_fix["PhungNg"]="Phung Nguyen"
  user_fix["Daniel Holme Huglen"]="Daniel Huglen"
  user_fix["MikaelSynnes"]="Mikael Synnes"
  user_fix["samtroll"]="Sammy Nordström"
  user_fix["Pertti Kroger"]="Pertti Kröger"
  user_fix["Korsneso"]="John Korsnes"
  user_fix["John10 Korsnes"]="John Korsnes"
  user_fix["johed"]="Johan Hedberg"

  # fix username mapping
  for k in "${!user_fix[@]}"; do
    cat combo.log | sed "s/|$k|/|${user_fix[$k]}|/" >x.log
    mv x.log combo.log
  done
}

fetch_avatars() {
  echo "Fetching avatars ..."

  # get github avatars
  for user in $(cat combo.log | awk -F '|' '{print $2}' | sort | uniq); do
    if [ ! -f "tmp/avatars/$user.jpg" ]; then
      curl -s -L "https://github.com/$user.png?size=512" -o "tmp/avatars/$user.jpg"
    fi
  done
}

summary() {
  # summary + dump to combo.csv for other purposes..
  cat combo.log | awk -F '|' '{print $2}' | sort | uniq -c | sort -n -r
  cat combo.log | sed 's/|/,/g; s/\///; s/\//,/;' >combo.csv
}

generate_gource_video() {
  echo "Generating gource video..."
  # generate gource video
  # gource combo.log -s 0.4 -i 0 -"1920x1080" --user-image-dir tmp/avatars --highlight-users --highlight-dirs --file-extensions --hide mouse,filenames --key --stop-at-end --output-ppm-stream - | ffmpeg -y  -r 60 -f image2pipe -vcodec ppm -i - -threads 0 -r 24000/1001 -b:v 6144k -bt 8192k -vcodec libx264 -pass 1 -flags +loop -me_method dia -g 250 -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -bf 16 -b_strategy 1 -i_qfactor 0.71 -cmp +chroma -subq 1 -me_range 16 -coder 1 -sc_threshold 40 -keyint_min 25 -refs 1 -trellis 0 -partitions -parti8x8-parti4x4-partp8x8-partp4x4-partb8x8 -analyzeduration 1000 -probesize 100000 -an "gource.mp4"
  # gource -2560x1440 --hide mouse,progress,files,filenames --output-ppm-stream out.ppm --background-colour 000000 --font-colour 336699 --highlight-users --highlight-colour F9CE22 --file-idle-time 0 --auto-skip-seconds 1 --seconds-per-day 0.1 --title "2021 Commits" --user-scale 1 --bloom-multiplier 0.5 --bloom-intensity 0.5 --key --file-extensions combo.log
  # ffmpeg -y -r 25 -f image2pipe -vcodec ppm -i out.ppm -vcodec libx264 -preset ultrafast -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 gource.mp4
}

main() {
    parse_args "$@"
    enable_expanded_output

    if [ ! $no_clone ]; then
      clone_repositories
    else
      echo "Skipping repository clone"
    fi

    fix_usernames
    fetch_avatars
    summary
    generate_gource_video
}

main "$@"
