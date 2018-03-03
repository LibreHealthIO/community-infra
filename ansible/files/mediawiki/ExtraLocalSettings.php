<?php

$wgUseInstantCommons = true;

$wgAuthenticationTokenVersion = "1";

$wgPasswordSender     = "noreply@librehealth.io";
$wgUserEmailUseReplyTo = "noreply@librehealth.io";

$wgEmergencyContact   = "infrastructure@librehealth.io";
$wgLogo = "$wgResourceBasePath/resources/assets/logo.png";

$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "http://creativecommons.org/licenses/by/4.0/";
$wgRightsText = "Attribution 4.0 International";
$wgRightsIcon = "https://i.creativecommons.org/l/by/4.0/88x31.png";


$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['*']['edit'] = false;

wfLoadExtension( 'Cite' );
wfLoadExtension( 'CiteThisPage' );
wfLoadExtension( 'ConfirmEdit' );
wfLoadExtension( 'Gadgets' );
wfLoadExtension( 'ImageMap' );
wfLoadExtension( 'InputBox' );
wfLoadExtension( 'Interwiki' );
wfLoadExtension( 'LocalisationUpdate' );
wfLoadExtension( 'Nuke' );
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'PdfHandler' );
wfLoadExtension( 'Poem' );
wfLoadExtension( 'Renameuser' );
wfLoadExtension( 'SpamBlacklist' );
wfLoadExtension( 'SyntaxHighlight_GeSHi' );
wfLoadExtension( 'TitleBlacklist' );
wfLoadExtension( 'WikiEditor' );

?>