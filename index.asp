<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2013, Web Solutions"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Job Report Manager</title>
	<style type="text/css">
		body
		{
			padding: 50px 10px 10px 10px;
		}
	</style>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript" src="js/jquery.tablesorter.min.js"></script>
	<script type="text/javascript" src="js/date.js"></script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var TreeGuid = '<%= session("TreeGuid") %>';
		var TreeType = '<%= session("TreeType") %>';
		var TreeDescent = '<%= session("TreeDescent") %>';
		var TreeParentGuid = '<%= session("TreeParentGuid") %>';
		var ProjectGuid = '<%= session("ProjectGuid") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		
		$(document).ready(function() {
			GetReports();
		});
		
		function GetReports()
		{
			$('#processing').modal('show');

			var strRQLXML = '<TREESEGMENT type="' + TreeType + '" action="load" guid="' + TreeGuid + '" descent="' + TreeDescent + '" parentguid="' + TreeParentGuid + '"/>';
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(retXML){
				var regHeadlinePageIDPattern = '(.+?)\\(PageID:.([0-9]+?)\\)';
				var regHeadlinePageID = new RegExp(regHeadlinePageIDPattern,'');
				var regStartTimeStatusPattern = 'Start:(.+)/Status:(.+)';
				var regStartTimeStatus = new RegExp(regStartTimeStatusPattern,'');
				var ReportGuid;
				var HeadlinePageID;
				var Headline;
				var PageID;
				var StartTimeStatus;
				var StartTime;
				var Status;
				var match;
				var TableRow;
				
				$(retXML).find('SEGMENT').each(function(){
					ReportGuid = $(this).attr('guid');
				
					HeadlinePageID = $(this).attr('value');
					match = regHeadlinePageID.exec(HeadlinePageID);
					
					if(match != null)
					{
						Headline = match[1];
						PageID = match[2];
					}
					else
					{
						Headline = HeadlinePageID;
						PageID = '-1';
					}

					StartTimeStatus = $(this).attr('col2value');
					match = regStartTimeStatus.exec(StartTimeStatus);
					
					if(match != null)
					{
						StartTime = FormatDateTime(match[1]);
						Status = match[2];
					}
					
					TableRow = '<tr>';
					TableRow += '<td><input type=checkbox name="' + ReportGuid + '"></td>';
					TableRow += '<td>' + PageID + '</td>';
					TableRow += '<td><a href="openreport.asp?TreeGuid=' + ReportGuid + '" onclick="ViewReport(this.href);return false;">' + Headline + '</a></td>';
					TableRow += '<td>' + StartTime + '</td>';
					TableRow += '<td>' + Status + '</td>';
					TableRow += '</tr>';
					
					$('#reporttable tbody').append(TableRow);
				});

				$("#reporttable").tablesorter({
					// sort on the 3rd column, order dsc 
					sortList: [[3,1]],
					headers: { 0: { sorter: false } } 
				});
				
				$('#processing').modal('hide');
			});
		}
		
		function FormatDateTime(InputDateTime)
		{
			var ReturnDateTime;
			ReturnDateTime = Date.parse(InputDateTime);
			
			if(ReturnDateTime == null)
			{
				return '';
			}
			return ReturnDateTime.toString('yyyy/MM/dd hh:mm tt');
		}
		
		function ViewReport(Link)
		{
			window.open(Link,"_blank","width=1024,height=768,left=50,top=100,toolbar=0,location=0,directories=0,status=1,menubar=0,scrollbars=1,resizable=1");
		}
		
		function ToggleLast30Reports(state)
		{
			var ReportsCount = $('#reporttable :checkbox').length;
			var Last30Reports;
			
			if(ReportsCount > 29)
			{
				Last30Reports = $('#reporttable :checkbox').slice(-30);
			}
			else
			{
				Last30Reports = $('#reporttable :checkbox');
			}
			
			$(Last30Reports).each(function()
			{
				this.checked = state;
			});
			
			return false;
		}
		
		function ToggleReports(state)
		{
			ToggleReports(state, null);
		}
		
		function ToggleReports(state, selector)
		{
			if(selector == null)
			{
				selector = '#reporttable :checkbox'
			}
			
			$(selector).each(function()
			{
				this.checked = state;
			});
			
			return false;
		}
		
		function DeleteSelectedReports()
		{
			$('#processing').modal('show');
		
			var DeleteJoBReportRql = '';
			$('#reporttable input:checked').each( function() {
				DeleteJoBReportRql += '<EXPORTREPORT guid="' + $(this).attr('name') + '" action="delete"/>';
			});
			
			var strRQLXML = '<PROJECT>' + DeleteJoBReportRql + '</PROJECT>';
			
			RqlConnectorObj.SendRql(strRQLXML, false, function(retXML){
				$('#processing').modal('hide');
			
				// refresh page
				location.reload(true);
			});
		}
	</script>
</head>
<body>
	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<div style="padding-left:15px;padding-right:15px;">
				<div class="btn-group">
					<a class="btn btn-info dropdown-toggle" data-toggle="dropdown" href="#">
						Select
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu" id="data-action">
						<li><a href="#" onclick="ToggleReports(false)">None</a></li>
						<li><a href="#" onclick="ToggleReports(true)">All</a></li>
						<li><a href="#" onclick="ToggleLast30Reports(true)">Last 30</a></li>
					</ul>
				</div>
				<button class="btn btn-danger" type="button" onclick="DeleteSelectedReports();">Delete Selected Report</button>
				<div class="pull-right">
					<button class="btn" type="button" onclick="window.close();">Close</button>
				</div>
			</div>
		</div>
	</div>
	<div id="processing" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3 id="myModalLabel">Processing</h3>
		</div>
		<div class="modal-body">
			<p>Please wait...</p>
		</div>
	</div>
	<table class="tablesorter table table-striped table-bordered" id="reporttable"> 
		<thead> 
			<tr> 
				<th></th>
				<th>Page ID</th> 
				<th>Headline</th> 
				<th>Start Time</th> 
				<th>Status</th> 
			</tr> 
		</thead> 
		<tbody>
		</tbody> 
	</table> 
</body>
</html>