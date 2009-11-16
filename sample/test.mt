<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8">
<title>ベンチマーク</title>
</head>
<body>
<? my %person = @_ ?>
<h1><?= $person{name} ?>について</h1>
<h2>名前</h2>
<div><?= $person{name} ?></div>
<h2>年齢</h2>
<div><?= $person{age} ?></div>
<h2>好きな言語</h2>
<ul>
<? foreach my $lang (@{ $person{favorites}->{languages} }) { ?>
<li><?= $lang ?></li>
<? } ?>
</ul>
<h2>好きな食べもの</h2>
<ul>
<? foreach my $food (@{ $person{favorites}->{foods} }) { ?>
<li><?= $food ?></li>
<? } ?>
</ul>
</body>
</html>
