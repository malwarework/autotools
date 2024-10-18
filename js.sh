subfinder -d domain.com | httpx -mc 200 | tee subdomains.txt && cat subdomains.txt | waybackurls | httpx -mc 200 | grep .js | tee js.txt
nuclei -l js.txt -t ~/nuclei-templates/exposures/ -o js_exposures_results.txt


