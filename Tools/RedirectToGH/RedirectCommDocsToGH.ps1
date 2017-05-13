## for now this is copied from another tool to modify Metadata on .md files

## this is similar but shoudl add metadata to redirect to the github page



## --- Functions ---

# read the header and store values in variables to be reused in the new header
function ReadHeaderOldTags($text) {
	
	$global:Title = ""
	$global:Description = ""
	$global:Author = ""
	$global:Manager = ""
	$global:Topic = ""
	$global:Service = ""
	$global:Workload = ""


	if ($text -Match "title: ") {
		$global:Title = "Has a title metatag"
	}
	<#
	if ($text -Match "description=`"*`"") {
		$global:Description = (($text -split "description=`"", 2)[1] -split "`"")[0]
	}
	
	if ($text -Match "services=`"*`"") {
		$global:Service = (($text -split "services=`"", 2)[1] -split "`"")[0]
	}
	
	if ($text -Match "authors=`"*`"") {
		$global:Author = (($text -split "authors=`"", 2)[1] -split "`"")[0]
	}
	
	if ($text -Match "managers=`"*`"") {
		$global:Manager = (($text -split "managers=`"", 2)[1] -split "`"")[0]
	}
	
	if ($text -Match "ms.topic=`"*`"") {
		$global:Topic = (($text -split "ms.topic=`"", 2)[1] -split "`"")[0]
	}
    #>
	return $text
}

# -- remove the old propoerties / tags sections
<#
function RemoveOldHeaders($text) {

	$text = ($text -Replace '(?s)<properties.*?/>',"")
	$text = ($text -Replace '(?s)<tags.*?/>',"")

	return $text
}
#>

<#
function AddNewHeader($text) {
	$Title = $Title.Replace(":","-")
	$Description = $Description.Replace(":","-")
	
	$NewHeader = "---"+$NEWLINE
	# $NewHeader += "# Sample for CSI"+$NEWLINE
	# $NewHeader += "# required metadata"+$NEWLINE
	$NewHeader += "title: "+$Title+$NEWLINE
	$NewHeader += "description: "+$Description +$NEWLINE
	#$NewHeader += "keywords: "+$Keywords+$NEWLINE
	if (($Author -eq "andygonusa") -or ($Author -eq "aldonetti")) {
		$NewHeader += "author: MSCommunityPubService"+$NEWLINE
	} else {
		$NewHeader += "author: "+$Author +$NEWLINE
	}
	
	# $NewHeader += "manager: "+$Manager+$NEWLINE
	$NewHeader += "ms.date: 06/01/2016"+$NEWLINE
	$NewHeader += "ms.topic: "+$Topic+$NEWLINE
	#$NewHeader += "ms.prod: "+$NEWLINE
	$NewHeader += "ms.service: "+$Service+$NEWLINE
	#$NewHeader += "ms.assetid: "+$NEWLINE
	#$NewHeader += "# optional metadata"+$NEWLINE
	#$NewHeader += "#ROBOTS: "+$NEWLINE
	#$NewHeader += "#audience:"+$NEWLINE
	#$NewHeader += "#ms.devlang: "+$NEWLINE
	#$NewHeader += "#ms.reviewer: "+$NEWLINE
	#$NewHeader += "#ms.suite: "+$NEWLINE
	#$NewHeader += "#ms.tgt_pltfrm:"+$NEWLINE
	#$NewHeader += "#ms.technology:"+$NEWLINE
	$NewHeader += "ms.custom: CommunityDocs"+$NEWLINE
	$NewHeader += "---"+$NEWLINE+$NEWLINE
	
	$text = $NewHeader + $text
	
	return $text
}
#>

function AddRedirectionTag($text, $nURL) {
	
    $header = ($text -split "---",3)[1]
    
    # should be
    # https://github.com/Microsoft/CommunityDocs-it-it/blob/live/MSDN/Cloud/Backup-e-DataSync-con-SQL-Azure-e-SQL-Server.md
    
	$NewHeader = "---"+$NEWLINE
    $NewHeader += "redirect_url: "+$nURL+$NEWLINE
	$NewHeader += $header
	$NewHeader += "---"+$NEWLINE+$NEWLINE
	
	$text = $NewHeader + ($text -split "---",3)[2]
	
	return $text
}

## -------------- MAIN ---------------- ##
$FileText = ""

$Title = ""
$Description = ""
$Author = ""
$Manager = ""
$Topic = ""
$Service = ""
$Workload = ""
$NEWLINE = "`r`n"

#this is just to test it on MSDN
$relFilePath = 'C:\BUILD\Microsoft\CommunityDocs-it-it\MSDN'
cd $relFilePath

Get-ChildItem *.md -Exclude TOC.md -Recurse |  ForEach-Object {
	
    $relURL = $_.FullName.Replace($relFilePath,"")
    $relURL = $relURL.Replace($_.Extension,"")
    $relURL = $relURL.Replace("\","/")
    
    $FileText = ""
	Get-Content $_.FullName -Raw -Encoding UTF8 | % {$FileText += $_ + "NEWLINE"}


	$Title = ""
	ReadHeaderOldTags($FileText)
	if( $Title -ne "" )  {
		# it does have a correct header and tags

		#define the new path/URL
		#base
		$newURL = "https://github.com/Microsoft/CommunityDocs-it-it/blob/live/MSDN" + $relURL

		$FileText = AddRedirectionTag $FileText $newURL
		#$FileText = RemoveOldHeaders($FileText)
		#$FileText = AddNewHeader($FileText)
		}
    
    #remove the originally added NEWLINE text
	#$FileText.Replace("NEWLINE","`r`n")  | Out-File $_.FullName -Force -Encoding UTF8
	$FileText = $FileText.Replace("NEWLINE","`r`n")  
	
	$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
	[System.IO.File]::WriteAllLines($_.Fullname,$FileText, $Utf8NoBomEncoding)
	} 



