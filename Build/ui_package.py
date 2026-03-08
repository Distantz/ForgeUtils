"""
This file packages multiple 
"""

import os, io
import argparse
import xml.etree.ElementTree as ET 


class PPUIPkgFileInfo():

    def __init__(self, path, content):
        self.name = path
        self.content = content

    def read(self, count=None):
        return self.content

    def close(self):
        pass

    def __str__(self):
        return f"<PPUIPkgFileInfo name='{self.name}' file_size={len(self.content)}>"


class PPUIPkgFile():

    def __init__(self, basic, path):
        self.basic = basic#'Mod_ProTrack/Main'
        self.files = []
        self.icons = []
        self.path  = path

    def __enter__(self):
        return self

    def __exit__(self, exception_type, exception_value, exception_traceback):
        self.close()
        pass

    def infolist(self):
        return self.files

    def namelist(self):
        return [o.name for o in self.files]

    def getinfo(self, path):
        return [o for o in self.files if o.name == path][0]
        pass

    def is_ppuipkgfile(self, path):
        pass

    def printdir(self):
        pass

    def remove(self, member):
        self.files.remove(member)

    def extract(self, member, path=None):
        self._write_file(os.path.join(path, '.', member.name), member.content)

    def extractall(self, path=None):
        for f in self.infolist():
            self.extract(f, path)

    def _write_file(self, path, content, overwrite = True):
        """ write  content to a file
        :param path: file path
        :param content: the content to write
        :return: content of the file
        """ 
        if overwrite == False and os.path.exists(path):
            return
        try:
            os.makedirs(os.path.dirname(path))
        except:
            pass
        with open(path, 'wb') as f:
            #print(f"Creating {path}")
            content = f.write(content)
            f.close
            return

    def open(self, path, mode='r'):
        if path in self.namelist():
            return self.getinfo(path)
        else:
            # make new
            pass

    def write(self, name, path):
        name = name.replace("\\","/")
        content = open(os.path.join(path, name), 'rb').read()
        self.files.append(PPUIPkgFileInfo(name, content))

    def close(self):
        self._write_files(self.path)

    def importall(self, path=None):
        ppkfiles = self._get_file_list(path)
        for name in ppkfiles:
            self.write(name, path)

    def _get_file_list(self, path):
        """ Gets a list of files from a folder """
        files = [os.path.relpath(val, path) for sublist in [[os.path.join(i[0], j) for j in i[2]] for i in os.walk(path)] for val in sublist]
        return files

    def _write_files(self, name, path=None):
        root = ET.Element('PPUIPKGRoot', 
          {
            'file_count': str(len(self.files)), 
            'icondata_count': '0', 
            'game' : "Planet Coaster 2" 
          }
        )
        basic_path = ET.SubElement(root, 'basic_path')
        basic_path.text = self.basic

        files = ET.SubElement(root, 'files')

        for fileInfo in self.files:
            file_size = len(fileInfo.content)
            file = ET.SubElement(files, 'ppuipkgfile', {'file_size' : str(file_size)})
            filename = ET.SubElement(file, 'file_name')
            filename.text = fileInfo.name.replace("\\","/")
            filedata = ET.SubElement(file, 'file_content')
            filedata.text = " ".join(  [str(byte) for byte in bytearray(fileInfo.content)] )

        types = ET.SubElement(root, 'types')
        f = open(name, 'wb')
        f.write( ET.tostring(root) )
        f.close()