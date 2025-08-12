class MethodMapperService
  # Reference: https://developers.payu.com/europe/pl/docs/get-started/integration-overview/references/#pbl
  PAY_METHODS_MAPPING = {
    # Polish online payments PLN
    'blik'  => 'BLIK',
    'm'     => 'mTransfer - mBank',
    'w'     => 'Przelew24 - Santander (form. BZ WBK)',
    'o'     => 'Pekao24Przelew - Bank Pekao',
    'i'     => 'Płacę z Inteligo',
    'p'     => 'Płać z iPKO',
    'g'     => 'Płać z ING',
    'gbx'   => 'Płacę z VeloBank',
    'l'     => 'Credit Agricole',
    'ab'    => 'Płacę z Alior Bankiem',
    'bn'    => 'Bank Nowy S.A.',
    'wm'    => 'Przelew z Millennium',
    'wc'    => 'Przelew z Citi Handlowego',
    'bo'    => 'Płać z BOŚ',
    'bnx'   => 'BNP Paribas',
    'bs'    => 'Banki Spółdzielcze',
    'nstb'  => 'Nest bank',
    'plsb'  => 'Plus Bank',
    'wys'   => 'Bank Pocztowy',
    'b'     => 'Przelew bankowy',

    # PayU Pay Later and installments PLN:
    'ai'       => 'PayU Raty',
    'dpkl'     => 'Klarna',
    'dpt'      => 'Twisto',
    'dpp'      => 'PayPo',
    'ppf'      => 'PragmaPay',
    'blikbnpl' => 'BLIK PayU Płacę Później',

    # Card payments
    'c'        => 'Card',
    'jp'       => 'Apple Pay',
    'ap'       => 'Google Pay',
    'vm'       => 'Visa Mobile'
  }.freeze

  # By default those payments return simply card payment, thus the information about used wallet
  # must be fetched from paymentFlow attribute.
  # Reference: https://developers.payu.com/europe/pl/docs/payment-flows/transaction-retrieve/#payment-flow-values
  PAYMENT_FLOWS_MAPPING = {
    'GOOGLE_PAY'           => 'Google Pay',
    'GOOGLE_PAY_TOKENIZED' => 'Google Pay',
    'APPLE_PAY'            => 'Apple Pay',
    'CLICK_TO_PAY'         => 'Click To Pay',
    'VISA_MOBILE'          => 'Visa Mobile',
  }.freeze

  def self.name_for(code, payment_flow)
    PAYMENT_FLOWS_MAPPING[payment_flow.to_s] || PAY_METHODS_MAPPING[code.to_s]
  end

  def self.all
    PAY_METHODS_MAPPING
  end
end
