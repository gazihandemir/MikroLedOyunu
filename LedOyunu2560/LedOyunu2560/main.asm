	cbi DDRD, 0 ; pull up direncini aktifle�tiriyoruz , portd yi ��k�� yap�yoruz 
	sbi PORTD, 0 ; portd nin 0. bitini set yap�yoruz 
	ldi r16, 0xFF ; portc yi giri� yapmak i�in i�ine FF yani b�t�n bitlerini 1 yapmam�z laz�m
	out DDRC, r16 ; portc nin ddrc sini giri� yapt�k
	ldi r16, 0x03 ; portb nin sadece 0. ve 1. bitini kullanaca��m�z i�in 0. ve 1. bitlerini set yap�yoruz yani 0000 0011 
	// portb nin 0. biti ledlere g�� verirken 1. biti displaye g�� verir
	out DDRB, r16 ; portc nin ddrc sini giri� yapt�k
	ldi r16, 0xFE ; ba�lang�� durumu i�in portc nin pinlerine FE y�kl�yoruz 1111 1110 , L0 clear, di�er ledler set olacak �ekilde
	sbi PORTB, 0 ; Ledler enerji vermek i�in portb nin 0 bitini set yap�yoruz ,not :displayin �al��mas� i�in portb nin 1. bitini kullanmak laz�m
	call wait ; Arduinomuz bozuk oldu�u i�in ba�lang��ta butondan gelecek 0 veya 1 leri engellemek i�in oyunumuzu biraz ge� ba�lat�yoruz 
	ldi r31,0xFE ; Tekrar oyuna ba�lamak i�in de�er atamas�


baslangicDurumu: ; ba�lang�� durumu i�in butona bas�lmad�k�a Ledlerde s�rekli FE de�erini g�rmek istiyoruz , butona bas�l�nca ters kara�im�ek devremiz ba�layacakt�r.
	LDI r25,0x00 ; burda seviyeleri belirlemek i�in kulland���m pinin atamas�n� yap�yoruz (seviye2)
	LDI r26,0x00 ; (seviye3)
	sbis PIND, 0 ; butona bas�lmad�k�a bir a�a��daki komutu atla , pind nin 0 . biti set ise atla , butona bas�lmay�nca 1 ,bas�ld��� zaman 0 de�erini g�r�r�z
	rjmp tersKarasimsek ; butona bas�l�nca ters kara�im�ek fonksiyonuna gidilecek
	out PORTC, r16 ; portc nin bitlerine-pinlerine FE de�erini ekle 
	rjmp baslangicDurumu ; butona bas�lmad�k�a sonsuz d�ng�de kalabilmek i�in rjmp komutunu kullan�yoruz 
	// as�l  ama� ba�lang�� durumuna sadece ba�lamak istedi�imiz zaman gitmek onun haricinde alttaki yazd���m�z fonksiyonu kullanmak
devamlilikDurumu: ; Butona bir kere bas�ld�ktan sonra ba�lang�� durumuna bir daha d�nmemek i�in ve s�reklili�i sa�lamak i�in yazd�k
	sbic PIND, 0 ; butona bas�lm��sa bir sonraki komutu atla, pind nin 0. biti clear ise atla 
	rjmp tersKarasimsek ; ters kara�im�ek fonksiyonuna git
	rjmp devamlilikDurumu  ; sonsuz d�ng�y� sa�lamak i�in tekrar devamlilikDurumu fonksiyonuna git 

tersKarasimsek: ; Ters kara�im�ek devresi
// 1 ve 2 diye ay�rmam�n amac� L0-L7 , L7-L0 i�inde s�rekli d�nd���n� d���nd���m�z i�in ve �rnekte g�sterilen normal kara�im�ek devresinden uyarlad���m�z i�in 
tersKarasimsek1: ; L0-L7 ledleri aras�nda gitme
	// r21 in de�erini kara�im�ek1 fonksiyonuna girdi�imiz zaman 0x00 ve kara�im�ek2 fonksiyonuna girdi�imiz zaman 0x01 yap�yoruz
	// ��nk� butona bas�ld���nda s�rekli kara�im�ek1 fonksiyona giriyordu bizde b�yle bir ��z�m geli�tirdik ve di�er gerekli fonksiyonlarda hangisine girmesi gerekti�ini kontrollerle belirttik
	ldi r21, 0x00 ; r21 = 0x00
	sbi PORTB,0 ; ledlere enerji vermek i�in portb nin 0. bitini set yap�yoruz 
	out PORTC, r16 ;  portc ye her seferinde farkl� de�erler y�klemek i�in out ile de�er y�kl�yoruz -> FE FD FB F7 BF DF EF
	cpse r16,r31 ; fonksiyonumuz ba�larken hata olu�uyordu , sadece ilk bas�lma durumunda hata olu�tu�u i�in r31 in i�ine FE y�kleyerek kontrol yapt�k
	// r16 == FE ve r31 == FE ise atla yani sadece ilk durum i�in atlama yap�yoruz 
	call butonaBasilmaDurumu
	call wait ; wait fonksiyonu ile ledlerin yanma s�resini yakla��k 300ms yap�yoruz 
	call butonaBasilmaDurumu // butona bas�ld���n�n kontrol�n� yap�yoruz bas�ld�ysa i�lemlerini yap�yor bas�lmad�ysa hi�bir�ey olmam�� gibi devam ediyor
	sec ; rol komutunun carry'ye g�re �al��t��� i�in sec komutuyla c bitini set yap�yoruz 1111 1110-> 1111 1101-> 1111 1011 => sola kayd�r�rken sa� taraftan carry bitinin de�eri geliyor 1 gelmesi i�in s�rekli carry'yi set yap�yoruz
	rol r16 ; carry ile sola kayd�rma komutu 
	call butonaBasilmaDurumu ; butona bas�ld�m� kontrol�
	cpi r16, 0x7F ; r16 7F den ��kart�larak z bitinin de�i�mesini sa�l�yoruz . e�er e�itse z biti 1 olur e�it de�ilse 0 olur 
	breq tersKarasimsek2 ; z biti 1 ise yani say�lar e�itse terskara�im�ek2 fonksiyonuna ge�i� yap�yoruz 
	rjmp tersKarasimsek1 ; z biti 0 ise terskara�im�ek1 fonksiyonumuzun ba��na rjmp ile geri d�n�yoruz 

tersKarasimsek2: ; L7-L0 ledleri aras� gitme
	ldi r21, 0x01 ; bunun a��klamas�n� terskara�im�ek1 fonksiyonu i�inde yapt�m => r21 = 0x01
	out PORTC, r16 ; portc nin i�ine de�er y�kleme
	call butonaBasilmaDurumu ; butona bas�lma kontrol� ; bunun detaylar�n� fonksiyonun  kendisinde a��klayaca��z
	call wait ; wait fonksiyonu ile ledlerin yanma s�resini yakla��k 300ms yap�yoruz 
	call butonaBasilmaDurumu ; butona bas�lma kontrol�
	sec ; carry set yapma komutu , bunun a��klamas�n� terskara�im�ek1de yapt�k , burdada sa�a kayd�rma yaparak carry ye g�re sol taraftan carry ye g�re 0 veya 1 geldi�i i�in s�rekli 1 getiriyoruz yani carry = 1 yaparak 0111 1111(7F) -> 1011 1111(BF) ..... durumuna getiriyoruz  
	ror r16 ; sa�a carry ile kayd�rma komutu
	call butonaBasilmaDurumu ; butona bas�lma kontrol�
	cpi r16, 0xFE ; r16 - FE i�lemi(��karma) yap�l�r ve e�it ise z biti 1 olur de�ilse z biti 0 olur 
	breq tersKarasimsek1 ; z biti 0 ise say�lar e�ittir ve terskara�im�ek1 fonksiyonuna gidilir
	rjmp tersKarasimsek2 ; z biti 1 ise say�lar e�it de�ildir ve terskara�im�ek2 fonksiyonunun ba��na geri gidilir

butonaBasilmaDurumu:
	// burdaki amac�m�z butona bas�lma kontrol�n� yapmakt�r, Butona bas�lmad���(pind o. biti = 1) taktirde hi�bir�ey olmuyor ve her�ey olmas� gerekti�i gibi devam ediyor
	// e�er butona bas�ld�(pind 0. biti = 0) ise seviye1 fonksiyonumuza gidiyoruz. 
	sbis PIND,0 ; butona bas�lmad��� taktirde pind nin 0. biti 1 oluyor ve sbis komutuyla pind nin 0. biti = 1 ise atla demek istiyoruz 
	call seviye1 ; butona bas�lm��sa seviye1 fonksiyonuna gidiyoruz 
	ret
			



seviye1:
// burdaki amac�m�z butona bas�ld���nda displayde tek �izgi yani 0x08 de�erini g�stermektir
// Oyunun kural�na g�re butona bas�ld���nda tek �izgi e�er ikinci butona bas�ld���nda ayn� ledi yakalam��sak 2. �izginin yanmas� gerekiyor biz burda bunu uyarlad�k
	cp r16,r25 ; r25 in de�eri 0x00 ile ba�ta o y�zden 1. bas�lmada iki �izginin yanmamas� i�in b�yle bir kontrol yap�yoruz ve breq seviye2 sat�r� ilk bas���m�zda �al��m�yor
	breq seviye2 ; e�er say�lar e�it ise yani z biti 1 ise seviye 2 ye git 
	mov r25,r16 ; burda butona bast���m�zda r16 n�n de�erini bir yerlerde tutmak i�in r25 in i�in r16 daki de�eri kopyal�yoruz
	call wait2 ; bekleme fonksiyonumuz 
	sbi PORTB,0 ; ledlere enerji vermek i�in portb nin 0. bitini set yap�yoruz
	call wait ; bekleme fonksiyonumuz 
	cbi PORTB,0 ; Led'ler ve display'e ayn� anda enerji veremedi�imiz i�in burda led'lerin enerjisini kesiyoruz yani portb nin 0. bitini clear(0) yap�yoruz
	ldi r17, 0x08 ; Displayde tek �iz�i yapmak i�in portc'nin i�ine 0x08 y�klememiz gerekiyor o y�zden r17 de�erine 0x08 y�kl�yoruz
	out PORTC, r17 ; portc'nin i�ine 0x08 y�klendi
	sbi PORTB, 1 ; Displayi �al��t�rmak i�in enerjisi vermemiz gerekiyor , o y�zden portb nin 1. bitini set(1) yap�yoruz
	call wait2 ; bekleme fonksiyonumuz , display�n yanmas� gerek s�re kadar bekliyoruz 
	cbi PORTB, 1 ; Led'leri tekrar yakmak i�in displayin g�c�n� kesiyoruz yani portb'nin 1. bitini clear(0) yap�yoruz
	sbi PORTB,0 ; ledlere enerji veriyorum 
	// a�a��daki 4 komut i�in amac�m�z terskara�im�ek devresinde hata ��kmas� ve s�rekli terskara�im�ek1 devresine ge�i� yapmas�d�r 
	ldi r22,0x00 ; r22 = 0
	cpse r21,r22 
	//(r21 = 0 ise ve r22 = 0 ise) => a�a��daki komut atlan�yor ve tersKara�im�ek1 fonksiyonuna gidiliyor.  
	//(r21 = 1 ise ve r22 = 0 ise) => a�a��daki komut atlanm�yor ve tersKara�im�ek2 fonksiyonuna gidiliyor.
	rjmp tersKarasimsek2
	rjmp tersKarasimsek1
seviye2:
// Bu fonksiyondaki amac�m�z 1. bast���m�z led 2. bast���m�z led ile ayn�m� onun kontrol�n� yapmak 
	cp r25,r26 ; r26 = 0 atamas� yapm��t�k o y�zden ilk bast���m�z zaman seviye3 fonksiyona gidi�imizi engellemek i�in b�yle bir yol izledim, ��nk� ilk bast���m�zda ayn� de�erler olmuyor , 3. kez ayn� ledi basmay� ba�ar�rsak seviye3 e gidiyor
	breq seviye3 ; say�lar e�it ise yani z biti 1 ise seviye3 e git 
	mov r26,r16 ; burda seviye3'e gitmek i�in r26'n�n i�ine r16 de�erini kopyal�yoruz 
	call wait2 ; bekleme fonksiyonumuz 
	sbi PORTB,0 ; ledlere enerji ver , portb'nin 0 biti set(1) yap�yoruz
	call wait ; bekleme fonksiyonumuz 
	cbi PORTB,0 ; Displayi g�� verce�imiz i�in ledlerin enerjisini kesiyoruz , portb'nin 0. biti clear(0)
	ldi r17, 0x09 ; Displayda iki tane �izgi g�sterce�imiz i�in 0x09 de�erini r17'nin i�ine at�yoruz . 0000 1001(0x09)
	out PORTC, r17 ; portc'nin bitlerine r17 yi y�kle
	sbi PORTB, 1 ; Displaye enerji ver , portb'nin 1. biti set(1) yap�yoruz
	call wait2 ; bekleme fonksiyonumuz 
	cbi PORTB, 1 ; Led'lere g�� verece�imiz i�in displayin g�c�n� kapat�yoruz , pinb'nin 1. bitini clear (0) yap�yoruz 
	sbi PORTB,0; ; Ledlere enerji  veriyoruz , pinb'nin 0. bitini set(1) yap�yoruz 
	//Alt sat�rdaki komutlar� seviye1 Fonksiyonu i�inde a��klad�k
	ldi r22,0x00
	cpse r21,r22
	rjmp tersKarasimsek2
	rjmp tersKarasimsek1


seviye3:
	call wait2 ; bekleme fonksiyonumuz 
	// bu fonksiyondaki as�l amac�m�z 3 kez �st �ste ayn� led i�in butona bas�ld�m� onu kontrol etmektir 
	sbi PORTB,0 ; led i�in enerji veriyoruz , portb'nin 0. bitini set(1) yap�yoruz
	call wait ; bekleme fonksiyonumuz
	cbi PORTB,0 ; led'leren enerjiyi kesmek i�in portb'nin 0. bitini clear(0) yap�yoruz.
	ldi r17, 0x49 ; Displayda 3 �izgi yanmas� i�in r17 nin i�ine 0x49 at�yoruz , 0100 1001
	out PORTC, r17 ; Portc ' nin i�ine r17 deki de�eri y�kl�yoruz 
	sbi PORTB, 1 ; Displaye enerji veriyoruz, portb'nin 1. bitini set(1) yap�yoruz 
	call wait2 ; bekleme fonksiyonumuz 
	cbi PORTB, 1 ; Led'lere g�� verece�imiz i�in displayin g�c�n� kapat�yoruz , pinb'nin 1. bitini clear (0) yap�yoruz 
	// a�ag�daki kodlar�n amac� 3. ad�m� tamamlad���m�zda yani 3 �izgiyi displayde g�sterdikten sonra hangi ledde durdu�unu tekrar displayde g�stermek
	// L0 -> displayde 0 say�s� , L1 -> dislayde 1 sayisi , L2 -> dislayde 2 sayisi, L3 -> dislayde 3 sayisi vb ....
	LDI r28,0xFE ; r28e FE de�erini at�yoruz ve kar��la�t�rma yap�yoruz. Oyunu tamamlad���m�z led FE(1111 1110) ise yani L0 ise z biti 1 oluyor ve brne komutuna girmiyip 0 yak�yoruz ve oyuna tekrardan ba�lamak i�in haz�r oluyoruz 
	cp r28,r26 ; ��karma i�lemi kontrol� yap�l�r 
	brne L0BasarisizlikDurumu ; e�er say�lar e�it de�ilse(z = 0) L0 a durmam�� demektir o y�zden bir L1 de mi durdu acaba diye bir sonraki fonksiyonumuza ge�i� yap�yoruz
	call sifirYak ; e�er z = 1 ise bu fonksiyon �a��r�l�r ve displayde 0 yak�l�p oyuna tekrar ba�lamak �zere beklenir  

L0BasarisizlikDurumu:
	LDI r28,0xFD ; r28e FD de�erini at�yoruz ve kar��la�t�rma yap�yoruz. Oyunu tamamlad���m�z led FD(1111 1101) ise yani L1 ise z biti 1 oluyor ve brne komutuna girmiyip 1 yak�yoruz ve oyuna tekrardan ba�lamak i�in haz�r oluyoruz 
	cp r28,r26 ; ��karma i�lemi kontrol� yap�l�r 
	brne L1BasarisizlikDurumu ; e�er say�lar e�it de�ilse(z = 0) L1 a durmam�� demektir o y�zden bir L2 de mi durdu acaba diye bir sonraki fonksiyonumuza ge�i� yap�yoruz
	call birYak ; e�er z = 1 ise bu fonksiyon �a��r�l�r ve displayde 1 yak�l�p oyuna tekrar ba�lamak �zere beklenir  
	
L1BasarisizlikDurumu:
	LDI r28,0xFB ; r28e FB de�erini at�yoruz ve kar��la�t�rma yap�yoruz. Oyunu tamamlad���m�z led FB(1111 1011) ise yani L2 ise z biti 1 oluyor ve brne komutuna girmiyip 2 yak�yoruz ve oyuna tekrardan ba�lamak i�in haz�r oluyoruz 
	cp r28,r26 ; ��karma i�lemi kontrol� yap�l�r 
	brne L2BasarisizlikDurumu ; e�er say�lar e�it de�ilse(z = 0) L2 a durmam�� demektir o y�zden bir L3 de mi durdu acaba diye bir sonraki fonksiyonumuza ge�i� yap�yoruz
	call ikiYak ; e�er z = 1 ise bu fonksiyon �a��r�l�r ve displayde 2 yak�l�p oyuna tekrar ba�lamak �zere beklenir 
	
L2BasarisizlikDurumu:
	LDI r28,0xF7 ; r28e F7 de�erini at�yoruz ve kar��la�t�rma yap�yoruz. Oyunu tamamlad���m�z led F7(1111 0111) ise yani L3 ise z biti 1 oluyor ve brne komutuna girmiyip 3 yak�yoruz ve oyuna tekrardan ba�lamak i�in haz�r oluyoruz 
	cp r28,r26 ; ��karma i�lemi kontrol� yap�l�r 
	brne L3BasarisizlikDurumu ; e�er say�lar e�it de�ilse(z = 0) L3 a durmam�� demektir o y�zden bir L4 de mi durdu acaba diye bir sonraki fonksiyonumuza ge�i� yap�yoruz
	call ucYak ; e�er z = 1 ise bu fonksiyon �a��r�l�r ve displayde 3 yak�l�p oyuna tekrar ba�lamak �zere beklenir 
	
L3BasarisizlikDurumu:
	LDI r28,0xEF ; r28e EF de�erini at�yoruz ve kar��la�t�rma yap�yoruz. Oyunu tamamlad���m�z led EF(1110 1111) ise yani L4 ise z biti 1 oluyor ve brne komutuna girmiyip 4 yak�yoruz ve oyuna tekrardan ba�lamak i�in haz�r oluyoruz 
	cp r28,r26 ; ��karma i�lemi kontrol� yap�l�r 
	brne L4BasarisizlikDurumu ; e�er say�lar e�it de�ilse(z = 0) L4 a durmam�� demektir o y�zden bir L5 de mi durdu acaba diye bir sonraki fonksiyonumuza ge�i� yap�yoruz
	call dortYak ; e�er z = 1 ise bu fonksiyon �a��r�l�r ve displayde 4 yak�l�p oyuna tekrar ba�lamak �zere beklenir 

L4BasarisizlikDurumu:
	LDI r28,0xDF ; r28e DF de�erini at�yoruz ve kar��la�t�rma yap�yoruz. Oyunu tamamlad���m�z led DF(1101 1111) ise yani L5 ise z biti 1 oluyor ve brne komutuna girmiyip 5 yak�yoruz ve oyuna tekrardan ba�lamak i�in haz�r oluyoruz 
	cp r28,r26 ; ��karma i�lemi kontrol� yap�l�r 
	brne L5BasarisizlikDurumu ; e�er say�lar e�it de�ilse(z = 0) L5 a durmam�� demektir o y�zden bir L6 de mi durdu acaba diye bir sonraki fonksiyonumuza ge�i� yap�yoruz
	call besYak ; e�er z = 1 ise bu fonksiyon �a��r�l�r ve displayde 5 yak�l�p oyuna tekrar ba�lamak �zere beklenir 

L5BasarisizlikDurumu:
	LDI r28,0xBF ; r28e BF de�erini at�yoruz ve kar��la�t�rma yap�yoruz. Oyunu tamamlad���m�z led BF(1011 1111) ise yani L6 ise z biti 1 oluyor ve brne komutuna girmiyip 6 yak�yoruz ve oyuna tekrardan ba�lamak i�in haz�r oluyoruz 
	cp r28,r26 ; ��karma i�lemi kontrol� yap�l�r 
	brne L6BasarisizlikDurumu ; e�er say�lar e�it de�ilse(z = 0) L6 a durmam�� demektir o y�zden bir L7 de mi durdu acaba diye bir sonraki fonksiyonumuza ge�i� yap�yoruz
	call altiYak ; e�er z = 1 ise bu fonksiyon �a��r�l�r ve displayde 6 yak�l�p oyuna tekrar ba�lamak �zere beklenir 
	
L6BasarisizlikDurumu:
	LDI r28,0x7F ; r28e 7F de�erini at�yoruz ve kar��la�t�rma yap�yoruz. Oyunu tamamlad���m�z led 7F(0111 1111) ise yani L7 ise z biti 1 oluyor ve brne komutuna girmiyip 7 yak�yoruz ve oyuna tekrardan ba�lamak i�in haz�r oluyoruz 
	cp r28,r26 ; ��karma i�lemi kontrol� yap�l�r 
	brne oyunuYenidenBaslat ; e�er say�lar e�it de�ilse(z = 0) L7 a durmam�� demektir.
	call yediYak ; e�er z = 1 ise bu fonksiyon �a��r�l�r ve displayde 7 yak�l�p oyuna tekrar ba�lamak �zere beklenir 
	
oyunuYenidenBaslat:
	// Oyunun yeniden ba�lamas� i�in r16 ya 0xFE de�erini at�yoruz ve ba�lang��Durumu fonksiyonumuza geri d�n�yoruz ve butona bir daha bas�lana kadar orda sonsuz d�ng� i�inde ledlerde FE yaparak bekliyoruz.
	call wait2
	ldi r16,0xFE
	sbi PORTB,0 ; ledlere enerji ver , portb'nin 0 biti set(1) yap�yoruz 
	rjmp baslangicDurumu

	// Burdaki amac�m�z Displaye g�� vererek displayde 0 say�s�n� g�stermektir 
sifirYak:
	sbi PORTB,1 ; displaye g�� ver 
	ldi r23,0x7E ; r23'e 0x7E(displayde 0 g�z�k�r) y�kle  
	out PORTC,r23 ; portc'ye 0x7E y�kle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yap�yoruz.
	ret

	// Burdaki amac�m�z Displaye g�� vererek displayde 1 say�s�n� g�stermektir 
birYak:
	sbi PORTB,1 ; displaye g�� ver 
	ldi r23,0x30 ; r23'e 0x30(displayde 1 g�z�k�r) y�kle 
	out PORTC,r23 ; portc'ye 0x30 y�kle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yap�yoruz.
	ret

	// Burdaki amac�m�z Displaye g�� vererek displayde 2 say�s�n� g�stermektir
ikiYak:
	sbi PORTB,1 ; displaye g�� ver 
	ldi r23,0x6D ; r23'e 0x6D(displayde 2 g�z�k�r) y�kle 
	out PORTC,r23 ; portc'ye 0x6D y�kle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yap�yoruz.
	ret

	// Burdaki amac�m�z Displaye g�� vererek displayde 2 say�s�n� g�stermektir
ucYak:
	sbi PORTB,1 ; displaye g�� ver 
	ldi r23,0x79 ; r23'e 0x79(displayde 3 g�z�k�r) y�kle 
	out PORTC,r23 ; portc'ye 0x79 y�kle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yap�yoruz.
	ret

dortYak:
	sbi PORTB,1 ; displaye g�� ver 
	ldi r23,0x33 ; r23'e 0x33(displayde 4 g�z�k�r) y�kle 
	out PORTC,r23 ; portc'ye 0x33 y�kle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yap�yoruz.
	ret

besYak:
	sbi PORTB,1 ; displaye g�� ver 
	ldi r23,0x5B ; r23'e 0x5B(displayde 5 g�z�k�r) y�kle 
	out PORTC,r23 ; portc'ye 0x5B y�kle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yap�yoruz.
	ret

altiYak:
	sbi PORTB,1 ; displaye g�� ver 
	ldi r23,0x5F ; r23'e 0x5F(displayde 6 g�z�k�r) y�kle 
	out PORTC,r23 ; portc'ye 0x5F y�kle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yap�yoruz.
	ret

yediYak:
	sbi PORTB,1 ; displaye g�� ver 
	ldi r23,0x70 ; r23'e 0x70(displayde 7 g�z�k�r) y�kle 
	out PORTC,r23 ; portc'ye 0x70 y�kle
	call wait3 ; bekleme fonksiyonumuz 
	cbi PORTB,1 ; displayden enerjiyi kes , Portb'nin 1. pinini clear(1) yap�yoruz.
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