	cbi DDRD, 0 ; pull up direncini aktifleþtiriyoruz , portd yi çýkýþ yapýyoruz 
	sbi PORTD, 0 ; portd nin 0. bitini set yapýyoruz 
	ldi r16, 0xFF ; portc yi giriþ yapmak için içine FF yani bütün bitlerini 1 yapmamýz lazým
	out DDRC, r16 ; portc nin ddrc sini giriþ yaptýk
	ldi r16, 0x03 ; portb nin sadece 0. ve 1. bitini kullanacaðýmýz için 0. ve 1. bitlerini set yapýyoruz yani 0000 0011 
	// portb nin 0. biti ledlere güç verirken 1. biti displaye güç verir
	out DDRB, r16 ; portc nin ddrc sini giriþ yaptýk
	ldi r16, 0xFE ; baþlangýç durumu için portc nin pinlerine FE yüklüyoruz 1111 1110 , L0 clear, diðer ledler set olacak þekilde
	sbi PORTB, 0 ; Ledler enerji vermek için portb nin 0 bitini set yapýyoruz ,not :displayin çalýþmasý için portb nin 1. bitini kullanmak lazým
	call wait ; Arduinomuz bozuk olduðu için baþlangýçta butondan gelecek 0 veya 1 leri engellemek için oyunumuzu biraz geç baþlatýyoruz 
	ldi r31,0xFE ; Tekrar oyuna baþlamak için deðer atamasý


baslangicDurumu: ; baþlangýç durumu için butona basýlmadýkça Ledlerde sürekli FE deðerini görmek istiyoruz , butona basýlýnca ters karaþimþek devremiz baþlayacaktýr.
	LDI r25,0x00 ; burda seviyeleri belirlemek için kullandýðým pinin atamasýný yapýyoruz (seviye2)
	LDI r26,0x00 ; (seviye3)
	sbis PIND, 0 ; butona basýlmadýkça bir aþaðýdaki komutu atla , pind nin 0 . biti set ise atla , butona basýlmayýnca 1 ,basýldýðý zaman 0 deðerini görürüz
	rjmp tersKarasimsek ; butona basýlýnca ters karaþimþek fonksiyonuna gidilecek
	out PORTC, r16 ; portc nin bitlerine-pinlerine FE deðerini ekle 
	rjmp baslangicDurumu ; butona basýlmadýkça sonsuz döngüde kalabilmek için rjmp komutunu kullanýyoruz 
	// asýl  amaç baþlangýç durumuna sadece baþlamak istediðimiz zaman gitmek onun haricinde alttaki yazdýðýmýz fonksiyonu kullanmak
devamlilikDurumu: ; Butona bir kere basýldýktan sonra baþlangýç durumuna bir daha dönmemek için ve sürekliliði saðlamak için yazdýk
	sbic PIND, 0 ; butona basýlmýþsa bir sonraki komutu atla, pind nin 0. biti clear ise atla 
	rjmp tersKarasimsek ; ters karaþimþek fonksiyonuna git
	rjmp devamlilikDurumu  ; sonsuz döngüyü saðlamak için tekrar devamlilikDurumu fonksiyonuna git 

tersKarasimsek: ; Ters karaþimþek devresi
// 1 ve 2 diye ayýrmamýn amacý L0-L7 , L7-L0 içinde sürekli döndüðünü düþündüðümüz için ve örnekte gösterilen normal karaþimþek devresinden uyarladýðýmýz için 
tersKarasimsek1: ; L0-L7 ledleri arasýnda gitme
	// r21 in deðerini karaþimþek1 fonksiyonuna girdiðimiz zaman 0x00 ve karaþimþek2 fonksiyonuna girdiðimiz zaman 0x01 yapýyoruz
	// çünkü butona basýldýðýnda sürekli karaþimþek1 fonksiyona giriyordu bizde böyle bir çözüm geliþtirdik ve diðer gerekli fonksiyonlarda hangisine girmesi gerektiðini kontrollerle belirttik
	ldi r21, 0x00 ; r21 = 0x00
	sbi PORTB,0 ; ledlere enerji vermek için portb nin 0. bitini set yapýyoruz 
	out PORTC, r16 ;  portc ye her seferinde farklý deðerler yüklemek için out ile deðer yüklüyoruz -> FE FD FB F7 BF DF EF
	cpse r16,r31 ; fonksiyonumuz baþlarken hata oluþuyordu , sadece ilk basýlma durumunda hata oluþtuðu için r31 in içine FE yükleyerek kontrol yaptýk
	// r16 == FE ve r31 == FE ise atla yani sadece ilk durum için atlama yapýyoruz 
	call butonaBasilmaDurumu
	call wait ; wait fonksiyonu ile ledlerin yanma süresini yaklaþýk 300ms yapýyoruz 
	call butonaBasilmaDurumu // butona basýldýðýnýn kontrolünü yapýyoruz basýldýysa iþlemlerini yapýyor basýlmadýysa hiçbirþey olmamýþ gibi devam ediyor
	sec ; rol komutunun carry'ye göre çalýþtýðý için sec komutuyla c bitini set yapýyoruz 1111 1110-> 1111 1101-> 1111 1011 => sola kaydýrýrken sað taraftan carry bitinin deðeri geliyor 1 gelmesi için sürekli carry'yi set yapýyoruz
	rol r16 ; carry ile sola kaydýrma komutu 
	call butonaBasilmaDurumu ; butona basýldýmý kontrolü
	cpi r16, 0x7F ; r16 7F den çýkartýlarak z bitinin deðiþmesini saðlýyoruz . eðer eþitse z biti 1 olur eþit deðilse 0 olur 
	breq tersKarasimsek2 ; z biti 1 ise yani sayýlar eþitse terskaraþimþek2 fonksiyonuna geçiþ yapýyoruz 
	rjmp tersKarasimsek1 ; z biti 0 ise terskaraþimþek1 fonksiyonumuzun baþýna rjmp ile geri dönüyoruz 

tersKarasimsek2: ; L7-L0 ledleri arasý gitme
	ldi r21, 0x01 ; bunun açýklamasýný terskaraþimþek1 fonksiyonu içinde yaptým => r21 = 0x01
	out PORTC, r16 ; portc nin içine deðer yükleme
	call butonaBasilmaDurumu ; butona basýlma kontrolü ; bunun detaylarýný fonksiyonun  kendisinde açýklayacaðýz
	call wait ; wait fonksiyonu ile ledlerin yanma süresini yaklaþýk 300ms yapýyoruz 
	call butonaBasilmaDurumu ; butona basýlma kontrolü
	sec ; carry set yapma komutu , bunun açýklamasýný terskaraþimþek1de yaptýk , burdada saða kaydýrma yaparak carry ye göre sol taraftan carry ye göre 0 veya 1 geldiði için sürekli 1 getiriyoruz yani carry = 1 yaparak 0111 1111(7F) -> 1011 1111(BF) ..... durumuna getiriyoruz  
	ror r16 ; saða carry ile kaydýrma komutu
	call butonaBasilmaDurumu ; butona basýlma kontrolü
	cpi r16, 0xFE ; r16 - FE iþlemi(çýkarma) yapýlýr ve eþit ise z biti 1 olur deðilse z biti 0 olur 
	breq tersKarasimsek1 ; z biti 0 ise sayýlar eþittir ve terskaraþimþek1 fonksiyonuna gidilir
	rjmp tersKarasimsek2 ; z biti 1 ise sayýlar eþit deðildir ve terskaraþimþek2 fonksiyonunun baþýna geri gidilir

butonaBasilmaDurumu:
	// burdaki amacýmýz butona basýlma kontrolünü yapmaktýr, Butona basýlmadýðý(pind o. biti = 1) taktirde hiçbirþey olmuyor ve herþey olmasý gerektiði gibi devam ediyor
	// eðer butona basýldý(pind 0. biti = 0) ise seviye1 fonksiyonumuza gidiyoruz. 
	sbis PIND,0 ; butona basýlmadýðý taktirde pind nin 0. biti 1 oluyor ve sbis komutuyla pind nin 0. biti = 1 ise atla demek istiyoruz 
	call seviye1 ; butona basýlmýþsa seviye1 fonksiyonuna gidiyoruz 
	ret
			



seviye1:
// burdaki amacýmýz butona basýldýðýnda displayde tek çizgi yani 0x08 deðerini göstermektir
// Oyunun kuralýna göre butona basýldýðýnda tek çizgi eðer ikinci butona basýldýðýnda ayný ledi yakalamýþsak 2. çizginin yanmasý gerekiyor biz burda bunu uyarladýk
	cp r16,r25 ; r25 in deðeri 0x00 ile baþta o yüzden 1. basýlmada iki çizginin yanmamasý için böyle bir kontrol yapýyoruz ve breq seviye2 satýrý ilk basýþýmýzda çalýþmýyor
	breq seviye2 ; eðer sayýlar eþit ise yani z biti 1 ise seviye 2 ye git 
	mov r25,r16 ; burda butona bastýðýmýzda r16 nýn deðerini bir yerlerde tutmak için r25 in için r16 daki deðeri kopyalýyoruz
	call wait2 ; bekleme fonksiyonumuz 
	sbi PORTB,0 ; ledlere enerji vermek için portb nin 0. bitini set yapýyoruz
	call wait ; bekleme fonksiyonumuz 
	cbi PORTB,0 ; Led'ler ve display'e ayný anda enerji veremediðimiz için burda led'lerin enerjisini kesiyoruz yani portb nin 0. bitini clear(0) yapýyoruz
	ldi r17, 0x08 ; Displayde tek çizði yapmak için portc'nin içine 0x08 yüklememiz gerekiyor o yüzden r17 deðerine 0x08 yüklüyoruz
	out PORTC, r17 ; portc'nin içine 0x08 yüklendi
	sbi PORTB, 1 ; Displayi çalýþtýrmak için enerjisi vermemiz gerekiyor , o yüzden portb nin 1. bitini set(1) yapýyoruz
	call wait2 ; bekleme fonksiyonumuz , displayýn yanmasý gerek süre kadar bekliyoruz 
	cbi PORTB, 1 ; Led'leri tekrar yakmak için displayin gücünü kesiyoruz yani portb'nin 1. bitini clear(0) yapýyoruz
	sbi PORTB,0 ; ledlere enerji veriyorum 
	// aþaðýdaki 4 komut için amacýmýz terskaraþimþek devresinde hata çýkmasý ve sürekli terskaraþimþek1 devresine geçiþ yapmasýdýr 
	ldi r22,0x00 ; r22 = 0
	cpse r21,r22 
	//(r21 = 0 ise ve r22 = 0 ise) => aþaðýdaki komut atlanýyor ve tersKaraþimþek1 fonksiyonuna gidiliyor.  
	//(r21 = 1 ise ve r22 = 0 ise) => aþaðýdaki komut atlanmýyor ve tersKaraþimþek2 fonksiyonuna gidiliyor.
	rjmp tersKarasimsek2
	rjmp tersKarasimsek1
seviye2:
// Bu fonksiyondaki amacýmýz 1. bastýðýmýz led 2. bastýðýmýz led ile aynýmý onun kontrolünü yapmak 
	cp r25,r26 ; r26 = 0 atamasý yapmýþtýk o yüzden ilk bastýðýmýz zaman seviye3 fonksiyona gidiþimizi engellemek için böyle bir yol izledim, çünkü ilk bastýðýmýzda ayný deðerler olmuyor , 3. kez ayný ledi basmayý baþarýrsak seviye3 e gidiyor
	breq seviye3 ; sayýlar eþit ise yani z biti 1 ise seviye3 e git 
	mov r26,r16 ; burda seviye3'e gitmek için r26'nýn içine r16 deðerini kopyalýyoruz 
	call wait2 ; bekleme fonksiyonumuz 
	sbi PORTB,0 ; ledlere enerji ver , portb'nin 0 biti set(1) yapýyoruz
	call wait ; bekleme fonksiyonumuz 
	cbi PORTB,0 ; Displayi güç verceðimiz için ledlerin enerjisini kesiyoruz , portb'nin 0. biti clear(0)
	ldi r17, 0x09 ; Displayda iki tane çizgi gösterceðimiz için 0x09 deðerini r17'nin içine atýyoruz . 0000 1001(0x09)
	out PORTC, r17 ; portc'nin bitlerine r17 yi yükle
	sbi PORTB, 1 ; Displaye enerji ver , portb'nin 1. biti set(1) yapýyoruz
	call wait2 ; bekleme fonksiyonumuz 
	cbi PORTB, 1 ; Led'lere güç vereceðimiz için displayin gücünü kapatýyoruz , pinb'nin 1. bitini clear (0) yapýyoruz 
	sbi PORTB,0; ; Ledlere enerji  veriyoruz , pinb'nin 0. bitini set(1) yapýyoruz 
	//Alt satýrdaki komutlarý seviye1 Fonksiyonu içinde açýkladýk
	ldi r22,0x00
	cpse r21,r22
	rjmp tersKarasimsek2
	rjmp tersKarasimsek1


seviye3:
	call wait2 ; bekleme fonksiyonumuz 
	// bu fonksiyondaki asýl amacýmýz 3 kez üst üste ayný led için butona basýldýmý onu kontrol etmektir 
	sbi PORTB,0 ; led için enerji veriyoruz , portb'nin 0. bitini set(1) yapýyoruz
	call wait ; bekleme fonksiyonumuz
	cbi PORTB,0 ; led'leren enerjiyi kesmek için portb'nin 0. bitini clear(0) yapýyoruz.
	ldi r17, 0x49 ; Displayda 3 çizgi yanmasý için r17 nin içine 0x49 atýyoruz , 0100 1001
	out PORTC, r17 ; Portc ' nin içine r17 deki deðeri yüklüyoruz 
	sbi PORTB, 1 ; Displaye enerji veriyoruz, portb'nin 1. bitini set(1) yapýyoruz 
	call wait2 ; bekleme fonksiyonumuz 
	cbi PORTB, 1 ; Led'lere güç vereceðimiz için displayin gücünü kapatýyoruz , pinb'nin 1. bitini clear (0) yapýyoruz 
	// aþagýdaki kodlarýn amacý 3. adýmý tamamladýðýmýzda yani 3 çizgiyi displayde gösterdikten sonra hangi ledde durduðunu tekrar displayde göstermek
	// L0 -> displayde 0 sayýsý , L1 -> dislayde 1 sayisi , L2 -> dislayde 2 sayisi, L3 -> dislayde 3 sayisi vb ....
	LDI r28,0xFE ; r28e FE deðerini atýyoruz ve karþýlaþtýrma yapýyoruz. Oyunu tamamladýðýmýz led FE(1111 1110) ise yani L0 ise z biti 1 oluyor ve brne komutuna girmiyip 0 yakýyoruz ve oyuna tekrardan baþlamak için hazýr oluyoruz 
	cp r28,r26 ; çýkarma iþlemi kontrolü yapýlýr 
	brne L0BasarisizlikDurumu ; eðer sayýlar eþit deðilse(z = 0) L0 a durmamýþ demektir o yüzden bir L1 de mi durdu acaba diye bir sonraki fonksiyonumuza geçiþ yapýyoruz
	call sifirYak ; eðer z = 1 ise bu fonksiyon çaðýrýlýr ve displayde 0 yakýlýp oyuna tekrar baþlamak üzere beklenir  

L0BasarisizlikDurumu:
	LDI r28,0xFD ; r28e FD deðerini atýyoruz ve karþýlaþtýrma yapýyoruz. Oyunu tamamladýðýmýz led FD(1111 1101) ise yani L1 ise z biti 1 oluyor ve brne komutuna girmiyip 1 yakýyoruz ve oyuna tekrardan baþlamak için hazýr oluyoruz 
	cp r28,r26 ; çýkarma iþlemi kontrolü yapýlýr 
	brne L1BasarisizlikDurumu ; eðer sayýlar eþit deðilse(z = 0) L1 a durmamýþ demektir o yüzden bir L2 de mi durdu acaba diye bir sonraki fonksiyonumuza geçiþ yapýyoruz
	call birYak ; eðer z = 1 ise bu fonksiyon çaðýrýlýr ve displayde 1 yakýlýp oyuna tekrar baþlamak üzere beklenir  
	
L1BasarisizlikDurumu:
	LDI r28,0xFB ; r28e FB deðerini atýyoruz ve karþýlaþtýrma yapýyoruz. Oyunu tamamladýðýmýz led FB(1111 1011) ise yani L2 ise z biti 1 oluyor ve brne komutuna girmiyip 2 yakýyoruz ve oyuna tekrardan baþlamak için hazýr oluyoruz 
	cp r28,r26 ; çýkarma iþlemi kontrolü yapýlýr 
	brne L2BasarisizlikDurumu ; eðer sayýlar eþit deðilse(z = 0) L2 a durmamýþ demektir o yüzden bir L3 de mi durdu acaba diye bir sonraki fonksiyonumuza geçiþ yapýyoruz
	call ikiYak ; eðer z = 1 ise bu fonksiyon çaðýrýlýr ve displayde 2 yakýlýp oyuna tekrar baþlamak üzere beklenir 
	
L2BasarisizlikDurumu:
	LDI r28,0xF7 ; r28e F7 deðerini atýyoruz ve karþýlaþtýrma yapýyoruz. Oyunu tamamladýðýmýz led F7(1111 0111) ise yani L3 ise z biti 1 oluyor ve brne komutuna girmiyip 3 yakýyoruz ve oyuna tekrardan baþlamak için hazýr oluyoruz 
	cp r28,r26 ; çýkarma iþlemi kontrolü yapýlýr 
	brne L3BasarisizlikDurumu ; eðer sayýlar eþit deðilse(z = 0) L3 a durmamýþ demektir o yüzden bir L4 de mi durdu acaba diye bir sonraki fonksiyonumuza geçiþ yapýyoruz
	call ucYak ; eðer z = 1 ise bu fonksiyon çaðýrýlýr ve displayde 3 yakýlýp oyuna tekrar baþlamak üzere beklenir 
	
L3BasarisizlikDurumu:
	LDI r28,0xEF ; r28e EF deðerini atýyoruz ve karþýlaþtýrma yapýyoruz. Oyunu tamamladýðýmýz led EF(1110 1111) ise yani L4 ise z biti 1 oluyor ve brne komutuna girmiyip 4 yakýyoruz ve oyuna tekrardan baþlamak için hazýr oluyoruz 
	cp r28,r26 ; çýkarma iþlemi kontrolü yapýlýr 
	brne L4BasarisizlikDurumu ; eðer sayýlar eþit deðilse(z = 0) L4 a durmamýþ demektir o yüzden bir L5 de mi durdu acaba diye bir sonraki fonksiyonumuza geçiþ yapýyoruz
	call dortYak ; eðer z = 1 ise bu fonksiyon çaðýrýlýr ve displayde 4 yakýlýp oyuna tekrar baþlamak üzere beklenir 

L4BasarisizlikDurumu:
	LDI r28,0xDF ; r28e DF deðerini atýyoruz ve karþýlaþtýrma yapýyoruz. Oyunu tamamladýðýmýz led DF(1101 1111) ise yani L5 ise z biti 1 oluyor ve brne komutuna girmiyip 5 yakýyoruz ve oyuna tekrardan baþlamak için hazýr oluyoruz 
	cp r28,r26 ; çýkarma iþlemi kontrolü yapýlýr 
	brne L5BasarisizlikDurumu ; eðer sayýlar eþit deðilse(z = 0) L5 a durmamýþ demektir o yüzden bir L6 de mi durdu acaba diye bir sonraki fonksiyonumuza geçiþ yapýyoruz
	call besYak ; eðer z = 1 ise bu fonksiyon çaðýrýlýr ve displayde 5 yakýlýp oyuna tekrar baþlamak üzere beklenir 

L5BasarisizlikDurumu:
	LDI r28,0xBF ; r28e BF deðerini atýyoruz ve karþýlaþtýrma yapýyoruz. Oyunu tamamladýðýmýz led BF(1011 1111) ise yani L6 ise z biti 1 oluyor ve brne komutuna girmiyip 6 yakýyoruz ve oyuna tekrardan baþlamak için hazýr oluyoruz 
	cp r28,r26 ; çýkarma iþlemi kontrolü yapýlýr 
	brne L6BasarisizlikDurumu ; eðer sayýlar eþit deðilse(z = 0) L6 a durmamýþ demektir o yüzden bir L7 de mi durdu acaba diye bir sonraki fonksiyonumuza geçiþ yapýyoruz
	call altiYak ; eðer z = 1 ise bu fonksiyon çaðýrýlýr ve displayde 6 yakýlýp oyuna tekrar baþlamak üzere beklenir 
	
L6BasarisizlikDurumu:
	LDI r28,0x7F ; r28e 7F deðerini atýyoruz ve karþýlaþtýrma yapýyoruz. Oyunu tamamladýðýmýz led 7F(0111 1111) ise yani L7 ise z biti 1 oluyor ve brne komutuna girmiyip 7 yakýyoruz ve oyuna tekrardan baþlamak için hazýr oluyoruz 
	cp r28,r26 ; çýkarma iþlemi kontrolü yapýlýr 
	brne oyunuYenidenBaslat ; eðer sayýlar eþit deðilse(z = 0) L7 a durmamýþ demektir.
	call yediYak ; eðer z = 1 ise bu fonksiyon çaðýrýlýr ve displayde 7 yakýlýp oyuna tekrar baþlamak üzere beklenir 
	
oyunuYenidenBaslat:
	// Oyunun yeniden baþlamasý için r16 ya 0xFE deðerini atýyoruz ve baþlangýçDurumu fonksiyonumuza geri dönüyoruz ve butona bir daha basýlana kadar orda sonsuz döngü içinde ledlerde FE yaparak bekliyoruz.
	call wait2
	ldi r16,0xFE
	sbi PORTB,0 ; ledlere enerji ver , portb'nin 0 biti set(1) yapýyoruz 
	rjmp baslangicDurumu

	// Burdaki amacýmýz Displaye güç vererek displayde 0 sayýsýný göstermektir 
sifirYak:
	sbi PORTB,1 ; displaye güç ver 
	ldi r23,0x7E ; r23'e 0x7E(displayde 0 gözükür) yükle  
	out PORTC,r23 ; portc'ye 0x7E yükle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yapýyoruz.
	ret

	// Burdaki amacýmýz Displaye güç vererek displayde 1 sayýsýný göstermektir 
birYak:
	sbi PORTB,1 ; displaye güç ver 
	ldi r23,0x30 ; r23'e 0x30(displayde 1 gözükür) yükle 
	out PORTC,r23 ; portc'ye 0x30 yükle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yapýyoruz.
	ret

	// Burdaki amacýmýz Displaye güç vererek displayde 2 sayýsýný göstermektir
ikiYak:
	sbi PORTB,1 ; displaye güç ver 
	ldi r23,0x6D ; r23'e 0x6D(displayde 2 gözükür) yükle 
	out PORTC,r23 ; portc'ye 0x6D yükle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yapýyoruz.
	ret

	// Burdaki amacýmýz Displaye güç vererek displayde 2 sayýsýný göstermektir
ucYak:
	sbi PORTB,1 ; displaye güç ver 
	ldi r23,0x79 ; r23'e 0x79(displayde 3 gözükür) yükle 
	out PORTC,r23 ; portc'ye 0x79 yükle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yapýyoruz.
	ret

dortYak:
	sbi PORTB,1 ; displaye güç ver 
	ldi r23,0x33 ; r23'e 0x33(displayde 4 gözükür) yükle 
	out PORTC,r23 ; portc'ye 0x33 yükle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yapýyoruz.
	ret

besYak:
	sbi PORTB,1 ; displaye güç ver 
	ldi r23,0x5B ; r23'e 0x5B(displayde 5 gözükür) yükle 
	out PORTC,r23 ; portc'ye 0x5B yükle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yapýyoruz.
	ret

altiYak:
	sbi PORTB,1 ; displaye güç ver 
	ldi r23,0x5F ; r23'e 0x5F(displayde 6 gözükür) yükle 
	out PORTC,r23 ; portc'ye 0x5F yükle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yapýyoruz.
	ret

yediYak:
	sbi PORTB,1 ; displaye güç ver 
	ldi r23,0x70 ; r23'e 0x70(displayde 7 gözükür) yükle 
	out PORTC,r23 ; portc'ye 0x70 yükle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yapýyoruz.
	ret


wait:
	push r21
	push r22
	ldi r21, 0x0D
	ldi r22, 0x00
	ldi r23, 0x00
	
_w0:
	dec r23
	brne _w0
	dec r22
	brne _w0
	dec r21
	brne _w0

	pop r22
	pop r21
	ret

wait2:
	push r21
	push r22

	ldi r21, 0x45
	ldi r22, 0x00
	ldi r23, 0x00

_w1:
	dec r23
	brne _w1
	dec r22
	brne _w1
	dec r21
	brne _w1

	pop r22
	pop r21
	ret

	wait3:
	push r21
	push r22

	ldi r21, 0x90
	ldi r22, 0x00
	ldi r23, 0x00

_w2:
	dec r23
	brne _w2
	dec r22
	brne _w2
	dec r21
	brne _w2

	pop r22
	pop r21
	ret