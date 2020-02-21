#! /usr/bin/env node
var childProcess = require('child_process')
var program = require('commander');
//console.log(childProcess);

// sudo btrfs quota enable /ssd
// sudo btrfs qgroup show  /1t | tail -n +3 | awk '{printf "%s\t%.2fG\t%.2fG\n", $1, $2/1024/1024/1024, $3/1024/1024/1024}'
// sudo btrfs subvolume list /ssd |grep -v subvolumes



function _subv_list(btrfs_mount, filter) {
  var command = "btrfs subvolume list "+btrfs_mount;
  if (filter != null && filter.length > 1) {
    command += " | grep -v "+filter;
  }
  command = "script -c '"+command+"' /dev/null | grep -v 'Script started, file is /dev/null' | grep -v 'Script done, file is /dev/null'";
  p = childProcess.spawnSync("bash", ["-c", command], { encoding: 'utf8' });
  // console.log(p.stdout);
  // console.log(command);
  
  var id_name = {};
  var lines = p.stdout.split('\n');
  for(var i = 0;i < lines.length;i++){
    var columns = lines[i].split(" ");
    //console.log(columns);
    if (columns.length == 9) {
      id_name[columns[1]] = columns[8];
    }
  }
  // console.log("code "+p.status);
  // console.log("end of exec\n");

  return id_name;
}

function _qgroup_show(btrfs_mount, id_name) {
  var command = "btrfs qgroup show  "+btrfs_mount+" | tail -n +3 | awk '\"'\"'{printf \"%s\\t%s\\t%s\\n\", $1, $2, $3}'\"'\"'";
  command = "script -c '"+command+"' /dev/null | grep -v 'Script started, file is /dev/null' | grep -v 'Script done, file is /dev/null'";
  p = childProcess.spawnSync("bash", ["-c", command], { encoding: 'utf8' });
  //console.log(p.stdout);
  //console.log(command);

  var fin_lines = [];
  fin_lines.push("ID\tTOTAL\tUNSHD\tSUBVOL")
  var lines = p.stdout.split('\n');
  for(var i = 0; i < lines.length; i++){
    var columns = lines[i].split("\t");
    //console.log(columns);
    if (columns.length != 3) {
      continue;
    }
    var subv_id = columns[0].split("/");
    if (subv_id.length < 2)
      continue;
    var subv_id = subv_id[subv_id.length-1];
    if (id_name.hasOwnProperty(subv_id)) {
      fin_lines.push(columns[0]+"\t"+columns[1]+"\t"+columns[2]+"\t"+id_name[subv_id]);
    }
  }
  return fin_lines;

}


program
  .version('0.0.1')
  .usage('[options]')

  .option('-p, --path [value]', 'Path of mounted BTRFS filesystem')
  .option('-f, --filter [value]', 'Filter (grep) by subvolume names')
  .parse(process.argv);

if (process.getuid() != 0) {
  console.log("you must be root");
  process.exit(1);
}

if (program.path == null) {
  console.log('argument -p is madatory');
  process.exit(1);
}

var btrfs_mount = program.path;
var filter = program.filter;

var id_name = _subv_list(btrfs_mount, filter);
var qg_sh = _qgroup_show(btrfs_mount, id_name);

console.log(qg_sh.join("\n"));

