class PayuMethodMapper
  MAPPING = {
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
    'b'     => 'Przelew bankowy'
  }.freeze

  def self.name_for(code)
    MAPPING[code.to_s] || code
  end

  def self.all
    MAPPING
  end
end
