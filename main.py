import os
import re

import geopandas as gpd
import click
from datetime import datetime, timedelta
from eodag import EODataAccessGateway

# Replace this with eotile later
s2_grid = gpd.read_file('s2_idx.geojson')

def get_geom_from_id(tile_id):
    return s2_grid[s2_grid['Name']==tile_id]

def get_dates_from_prod_id(product_id):
    pid = product_id.split("_")
    sat_name = pid[0]
    sensor = ""
    if 'S1' in sat_name: 
        res = re.search(r"(?<=\_)(\d){8}(?=T)",product_id)
        date_tmp = res.group()
        sensor = 'S1'
    elif 'S2' in sat_name:
        res = re.search(r"(?<=\_)(\d){8}(?=T)",product_id)
        date_tmp = res.group()
        sensor = 'S2'
    elif 'LC08' in sat_name:
        sensor = 'L8'
        date_tmp = pid[3]
    year = int(date_tmp[:4])
    month = int(date_tmp[4:6])
    day = int(date_tmp[6:8])
    date = datetime(year, month, day)
    start_date = date - timedelta(days=1)
    end_date = date + timedelta(days=1)
    return start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d"),sensor

def donwload_s1tiling_style(dag,eodag_product,out_dir):
    tmp_dir=os.path.join(out_dir,'tmp_'+eodag_product.properties['id'])
    if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)
    dag.download(eodag_product,outputs_prefix=tmp_dir)
    prod = os.listdir(tmp_dir)[0]
    prod_id = prod.split('_')
    dwn_prod = os.path.join(tmp_dir,prod)
    print(dwn_prod)
    os.system(f'mv {dwn_prod} {dwn_prod}.SAFE')
    os.system(f'mkdir {dwn_prod}')
    os.system(f'mv {dwn_prod}.SAFE {dwn_prod}')
    os.system(f'mv {dwn_prod} {out_dir}')
    vv_name = f's1a-iw-grd-vv-{prod_id[4].lower()}-{prod_id[5].lower()}-{prod_id[6].lower()}-{prod_id[7].lower()}-{prod_id[8].lower()}-001'
    vh_name = f's1a-iw-grd-vh-{prod_id[4].lower()}-{prod_id[5].lower()}-{prod_id[6].lower()}-{prod_id[7].lower()}-{prod_id[8].lower()}-002'
    base = f"{out_dir}/{prod}/{prod}.SAFE"

    os.rename(f'{base}/{"annotation"}/iw-vh.xml',f'{base}/{"annotation"}/{vh_name}.xml')
    os.rename(f'{base}/{"annotation"}/iw-vv.xml',f'{base}/{"annotation"}/{vv_name}.xml')
    os.rename(f'{base}/{"measurement"}/iw-vh.tiff',f'{base}/{"measurement"}/{vh_name}.tiff')
    os.rename(f'{base}/{"measurement"}/iw-vv.tiff',f'{base}/{"measurement"}/{vv_name}.tiff')

    os.system(f'rm -r {tmp_dir}')



@click.command('download')
@click.option('-t','--tile_id',help="S2 tile id")
@click.option('-s','--start_date',help="start date for your products search,format YYYY-mm-dd")
@click.option('-e','--end_date',help="end date for your products search,format YYYY-mm-dd")
@click.option('-pt','--product_type',help="Product type,for aws use generic types ex: sentinel1_l1c_grd/sentinel2_l1c/landsat8_l1tp")
@click.option('-pv','--provider',help="EOdag provider ex astraea_eod/peps/theia")
@click.option('-o','--out_dir',help="Output directory")
@click.option('-cfg','--config_file',help="EOdag config file")
def eodag_prods(tile_id,start_date,end_date,product_type,out_dir,config_file,provider="peps"):
    df = get_geom_from_id(tile_id)
    bbox = df.total_bounds
    extent = {'lonmin': bbox[0], 'latmin': bbox[1], 'lonmax': bbox[2], 'latmax': bbox[3]}
    dag = EODataAccessGateway(config_file)
    dag.set_preferred_provider(provider)
    products, est = dag.search(productType=product_type, start=start_date, end=end_date, geom=extent, items_per_page=200,cloudCover=70)
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    dag.download_all(products,outputs_prefix=out_dir)


@click.command('eodag_id')
@click.option('-t','--s2_tile_id',help="S2 tile id")
@click.option('-pid','--product_id',help="Product id from the plan json")
@click.option('-pv','--provider',help="EOdag provider ex astraea_eod/peps/theia",default='astraea_eod')
@click.option('-o','--out_dir',help="Output directory")
@click.option('-cfg','--config_file',help="EOdag config file")
def eodag_by_ids(s2_tile_id,product_id,out_dir,provider,config_file=None):
    # Extract dates and sensor from product id
    start_date,end_date,sensor = get_dates_from_prod_id(product_id)
    prods_types = {"S2":{"peps": "S2_MSI_L1C", "astraea_eod": "sentinel2_l1c"},"S1": {"peps": "S1_SAR_GRD", "astraea_eod": "sentinel1_l1c_grd"},"L8":{"astraea_eod": "landsat8_l1tp"}}
    product_type = prods_types[sensor][provider.lower()]
    # Get s2 tile footprint from external file (to be replaced by eotile)
    df = get_geom_from_id(s2_tile_id)
    bbox = df.total_bounds
    extent = {'lonmin': bbox[0], 'latmin': bbox[1], 'lonmax': bbox[2], 'latmax': bbox[3]}

    if config_file is None:
        dag = EODataAccessGateway()
        astraea_eod = '''
                    astraea_eod:
                        priority: 2 # Lower value means lower priority (Default: 0)
                        search:   # Search parameters configuration
                        auth:
                            credentials:
                                aws_access_key_id:
                                aws_secret_access_key:
                                aws_profile: 
                        download:
                            outputs_prefix:
            '''
        # Do not put the aws credentials here, they are parsed from env vars
        dag.update_providers_config(astraea_eod)
        dag.set_preferred_provider("astraea_eod")
    else:
        dag = EODataAccessGateway(config_file)
        print(provider)
        dag.set_preferred_provider(provider)
    products, est = dag.search(productType=product_type, start=start_date, end=end_date, geom=extent, items_per_page=200,cloudCover=70)
    final_product = [prod for prod in products if prod.properties["id"]==product_id][0]

    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    manifest_key = os.path.split(final_product.assets['vv']['href'])[0].replace('measurement','manifest.safe')
    final_product.assets['manifest']={}
    final_product.assets['manifest']['href']=manifest_key
    #dag.download(final_product,outputs_prefix=out_dir)
    donwload_s1tiling_style(dag,final_product,out_dir)
    

if __name__ == "__main__":
    eodag_by_ids()

