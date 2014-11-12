<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="expires" content="-1"/>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="copyright" content="2014, Web Solutions"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>Job Report Manager</title>
	<link rel="stylesheet" href="css/custom.css" />
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<script type="text/javascript" src="js/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/handlebars-v2.0.0.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script type="text/javascript" src="js/jquery.tablesorter.min.js"></script>
	<script type="text/javascript" src="js/date.js"></script>
	<script type="text/javascript" src="js/job-report-manager.js"></script>
	<script id="template-reports" type="text/x-handlebars-template" data-container="#reports" data-action="replace">
		<table class="tablesorter table table-striped table-bordered"> 
			<thead> 
				<tr> 
					<th>Page ID</th> 
					<th>Headline</th> 
					<th>Start Time</th> 
					<th>Status</th> 
				</tr> 
			</thead> 
			<tbody>
				{{#each reports}}
				<tr>
					<td>
						<label class="checkbox">
							<input type="checkbox" name="{{guid}}"> {{pageid}}
						</label>
					</td>
					<td><div class="btn btn-link" id="{{guid}}">{{headline}}</div></td>
					<td>{{starttime}}</td>
					<td>{{status}}</td>
				</tr>
				{{/each}}
			</tbody> 
		</table> 
	</script>
	<script id="template-navbar" type="text/x-handlebars-template" data-container=".navbar" data-action="replace">
		<div class="navbar-inner">
			<div class="navbar-padding">
				<div class="btn-group">
					<a class="btn btn-info dropdown-toggle" data-toggle="dropdown" href="#">
						Select
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu" id="data-action">
						<li><a href="#" class="select-none">None</a></li>
						<li><a href="#" class="select-all">All</a></li>
					</ul>
				</div>
				<button class="btn btn-danger delete-reports" type="button">Delete Selected Report</button>
				<div class="pull-right">
					<button class="btn" type="button" onclick="window.close();">Close</button>
				</div>
			</div>
		</div>
	</script>
	<script id="template-processing" type="text/x-handlebars-template" data-container="#processing" data-action="replace">
		<div class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="" aria-hidden="true">
			<div class="modal-body">
				<div class="loading">
					<img src="img/loading.gif" />
				</div>
			</div>
		</div>
	</script>
	<script id="template-report" type="text/x-handlebars-template" data-container="#report" data-action="replace">
		<div class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="" aria-hidden="true">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
				<h3 id="myModalLabel">{{name}}</h3>
			</div>
			<div class="modal-body">
				<div class="loading">
					<img src="img/loading.gif" />
				</div>
			</div>
			<div class="modal-footer">
				<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
			</div>
		</div>
	</script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var TreeGuid = '<%= session("TreeGuid") %>';
		var TreeType = '<%= session("TreeType") %>';
		var TreeDescent = '<%= session("TreeDescent") %>';
		var TreeParentGuid = '<%= session("TreeParentGuid") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		
		$(document).ready(function() {
			var JobReportManagerObj = new JobReportManager(RqlConnectorObj, TreeType, TreeGuid, TreeDescent, TreeParentGuid);
		});
	</script>
</head>
<body>
	<div class="navbar navbar-inverse navbar-fixed-top">
	</div>
	<div id="processing">
	</div>
	<div id="report">
	</div>
	<div id="reports">
		<div class="loading">
			<img src="img/loading.gif" />
		</div>
	</div>
</body>
</html>