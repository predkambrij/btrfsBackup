var childProcess = require('child_process')
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
  var command = "btrfs qgroup show  "+btrfs_mount+" | tail -n +3 | awk '\"'\"'{printf \"%s\\t%.2fG\\t%.2fG\\n\", $1, $2/1024/1024/1024, $3/1024/1024/1024}'\"'\"'";
  command = "script -c '"+command+"' /dev/null | grep -v 'Script started, file is /dev/null' | grep -v 'Script done, file is /dev/null'";
  p = childProcess.spawnSync("bash", ["-c", command], { encoding: 'utf8' });
  // console.log(p.stdout);
  // console.log(command);

  var fin_lines = [];
  var lines = p.stdout.split('\n');
  for(var i = 0;i < lines.length;i++){
    var columns = lines[i].split("\t");
    //console.log(columns);
    if (columns.length != 3) {
      continue;
    }
    var subv_id = columns[0].substring(2);
    if (id_name.hasOwnProperty(subv_id)) {
      fin_lines.push(columns[0]+"\t"+columns[1]+"\t"+columns[2]+"\t"+id_name[subv_id]);
    }
  }
  return fin_lines;

}

var btrfs_mount = "/ssd"
var btrfs_mount = "/1t"
var filter = "subvolumes";
var filter = null;
var id_name = _subv_list(btrfs_mount, filter);
var qg_sh = _qgroup_show(btrfs_mount, id_name);

//console.log(qg_sh);
console.log(qg_sh.join("\n"));

//console.log("end");

