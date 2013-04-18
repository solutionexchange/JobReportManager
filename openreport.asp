<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2013, Web Solutions"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Job Report</title>
	<style type="text/css">
		body
		{
			padding: 50px 10px 10px 10px;
		}
	</style>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="Rqlconnector.js"></script>
	<script type="text/javascript" src="js/jquery.tablesorter.min.js"></script>
	<script type="text/javascript" src="js/date.js"></script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var TreeGuid = '<%= Request.QueryString("TreeGuid") %>';
		var ProjectGuid = '<%= session("ProjectGuid") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		
		$(document).ready(function() {
			GetReport('ReportArea', TreeGuid);
		});
		
		function GetReport(AreaId, ReportGuid)
		{
			var strRQLXML = '<PROJECT><EXPORTREPORT guid="' + ReportGuid + '" action="view" format="1"/></PROJECT>';

			RqlConnectorObj.SendRql(strRQLXML, true, function(retXML){
				$('#' + AreaId).html(retXML);
			});
		}
	</script>
</head>
<body>
	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<div style="padding-left:15px;padding-right:15px;">
				<div class="pull-right">
					<button class="btn" type="button" onclick="window.close();">Close</button>
				</div>
			</div>
		</div>
	</div>
	<div id="ReportArea"></div>
</body>
</html>