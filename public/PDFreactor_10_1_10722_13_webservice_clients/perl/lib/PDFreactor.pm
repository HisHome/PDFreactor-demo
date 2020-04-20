# RealObjects PDFreactor Perl Wrapper version 7
# https://www.pdfreactor.com
# 
# Released under the following license:
# 
# The MIT License (MIT)
# 
# Copyright (c) 2015-2020 RealObjects GmbH
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

package PDFreactor;
    use LWP::UserAgent;
    use LWP::Protocol::https;
    use HTTP::Request;
    use HTTP::Headers;
    use HTTP::Cookies;
    use JSON;
    
    sub new {
        $self=shift;
        $url=shift;
        if (not(defined($url)) || $url eq "" || $url eq NULL) {
            $url = "http://localhost:9423/service/rest"; 
        }
        if ($url =~ /\/$/) {
            chop($url);
        }
        my $ref={
            apiKey => ""
        };
        bless($ref, $self);
    }
    sub getDocumentUrl {
        my $self = shift;
        my $documentId = shift;
        if (defined($documentId) && not($documentId eq "")) {
            return $url . "/document/" . $documentId;
        }
    }
    sub getProgressUrl {
        my $self = shift;
        my $documentId = shift;
        if (defined($documentId) && not($documentId eq "")) {
            return $url . "/progress/" . $documentId;
        }
    }
    sub convert {
        $self = shift;
        my %config = %{shift()};
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        if (%config) {
            $config{clientName} = "PERL";
            $config{clientVersion} = VERSION();
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/convert.json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(POST => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $json = encode_json \%config;
        $request->content($json);
        $request->content_type("application/json; charset=utf-8");
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            return decode_json ($response->content);
        } elsif ($status == 422) {
            die decode_json($response->content)->{'error'};
        } elsif ($status == 400) {
            die "Invalid client data. ".decode_json($response->content)->{'error'};
        } elsif ($status == 401) {
            die "Unauthorized. ".decode_json($response->content)->{'error'};
        } elsif ($status == 413) {
            die "The configuration is too large to process.";
        } elsif ($status == 500) {
            die decode_json($response->content)->{'error'};
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub convertAsBinary {
        $self = shift;
        my %config = %{shift()};
        my $stream = shift();
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        if (%config) {
            $config{clientName} = "PERL";
            $config{clientVersion} = VERSION();
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/convert.bin";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(POST => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $json = encode_json \%config;
        $request->content($json);
        $request->content_type("application/json; charset=utf-8");
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            if (defined $stream) {
                binmode($stream);
                $bytes = 2 * 1024;
                $chunk = $response->content($bytes);
                while ($chunk ne $bytes) {
                    $stream->write($chunk);
                    $chunk = $response->content($bytes);
                }
                close($stream);
            } else {
                return $response->content;
            }
        } elsif ($status == 422) {
            die $response->content;
        } elsif ($status == 400) {
            die "Invalid client data. ".$response->content;
        } elsif ($status == 401) {
            die "Unauthorized. ".$response->content;
        } elsif ($status == 413) {
            die "The configuration is too large to process.";
        } elsif ($status == 500) {
            die $response->content;
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub convertAsync {
        $self = shift;
        my %config = %{shift()};
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        if (%config) {
            $config{clientName} = "PERL";
            $config{clientVersion} = VERSION();
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/convert/async.json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(POST => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $json = encode_json \%config;
        $request->content($json);
        $request->content_type("application/json; charset=utf-8");
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            my $location = $response->header("Location");
            $documentId = substr($location, rindex($location, "/") + 1);
            my $cookiesHeader = $response->header('Set-Cookie');
            if (!$cookiesHeader eq '' && defined $connectionSettings) {
                if (!defined $connectionSettings->{cookies}) {
                    $connectionSettings->{cookies} = ();
                }
                $cookie_jar = HTTP::Cookies->new();
                $cookie_jar->extract_cookies($response);
                sub extractCookies {
                    my $version = shift();
                    my $cookieName = shift();
                    my $cookieValue = shift();
                    $connectionSettings->{cookies}->{$cookieName} = $cookieValue;
                }
                $cookie_jar->scan(\&extractCookies);
            }
            return $documentId;
        } elsif ($status == 422) {
            die decode_json($response->content)->{'error'};
        } elsif ($status == 400) {
            die "Invalid client data. ".decode_json($response->content)->{'error'};
        } elsif ($status == 401) {
            die "Unauthorized. ".decode_json($response->content)->{'error'};
        } elsif ($status == 413) {
            die "The configuration is too large to process.";
        } elsif ($status == 500) {
            die decode_json($response->content)->{'error'};
        } elsif ($status == 503) {
            die "Asynchronous conversions are unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub getProgress {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/progress/" .$documentId. ".json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(GET => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            return decode_json ($response->content);
        } elsif ($status == 404) {
            die "Document with the given ID was not found. ".decode_json($response->content)->{'error'};
        } elsif ($status == 401) {
            die "Unauthorized. ".decode_json($response->content)->{'error'};
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub getDocument {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/document/" .$documentId. ".json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(GET => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            return decode_json ($response->content);
        } elsif ($status == 404) {
            die "Document with the given ID was not found. ".decode_json($response->content)->{'error'};
        } elsif ($status == 401) {
            die "Unauthorized. ".decode_json($response->content)->{'error'};
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub getDocumentAsBinary {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $stream = shift();
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/document/" .$documentId. ".bin";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(GET => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            if (defined $stream) {
                binmode($stream);
                $bytes = 2 * 1024;
                $chunk = $response->content($bytes);
                while ($chunk ne $bytes) {
                    $stream->write($chunk);
                    $chunk = $response->content($bytes);
                }
                close($stream);
            } else {
                return $response->content;
            }
        } elsif ($status == 404) {
            die "Document with the given ID was not found. ".$response->content;
        } elsif ($status == 401) {
            die "Unauthorized. ".$response->content;
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub getDocumentMetadata {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/document/metadata/" .$documentId. ".json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(GET => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            return decode_json ($response->content);
        } elsif ($status == 404) {
            die "Document with the given ID was not found. ".decode_json($response->content)->{'error'};
        } elsif ($status == 401) {
            die "Unauthorized. ".decode_json($response->content)->{'error'};
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub deleteDocument {
        $self = shift;
        my $documentId = shift;
        if (not(defined($documentId))) {
            return {};
        }
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/document/" .$documentId. ".json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(DELETE => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            return;
        } elsif ($status == 404) {
            die "Document with the given ID was not found. ".decode_json($response->content)->{'error'};
        } elsif ($status == 401) {
            die "Unauthorized. ".decode_json($response->content)->{'error'};
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub getVersion {
        $self = shift;
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/version.json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(GET => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            return decode_json ($response->content);
        } elsif ($status == 401) {
            die "Unauthorized. ".decode_json($response->content)->{'error'};
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
    }
    sub getStatus {
        $self = shift;
        my $connectionSettings = shift();
        if (ref($stream) eq 'HASH') {
            $connectionSettings = $stream;
            $stream = undef;
        }
        my $headers = HTTP::Headers->new;
        my $cookieStr = "";
        if (defined $connectionSettings && defined $connectionSettings->{cookies}) {
            foreach my $key (keys $connectionSettings->{cookies}) {
                $cookieStr .= $key . "=" . $connectionSettings->{cookies}->{$key} . "; ";
            }
        }
        if (defined $connectionSettings && defined $connectionSettings->{headers}) {
            foreach my $key (keys $connectionSettings->{headers}) {
                $headers->header($key => $connectionSettings->{headers}->{$key});
            }
        }
        if (!$cookieStr eq "") {
            $headers->header("Cookie" => substr($cookieStr, 0, -2));
        }
        $headers->header("User-Agent" => "PDFreactor Perl API v7");
        $headers->header("X-RO-User-Agent" => "PDFreactor Perl API v7");
        my $restUrl = $url."/status.json";
        if (defined($self->{apiKey}) && $self->{apiKey} ne "" && $self->{apiKey} ne NULL) {
            $restUrl .= "?apiKey=" . $self->{apiKey};
        }
        my $request = HTTP::Request->new(GET => $restUrl, $headers);
        my $userAgent = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 }, max_redirect => 0);
        my $response = $userAgent->request($request);
        my $status = $response->code;
        if ($status >= 200 && $status <= 204) {
            return 1;
        } elsif ($status == 401) {
            die "Unauthorized. ".decode_json($response->content)->{'error'};
        } elsif ($status == 503) {
            die "PDFreactor Web Service is unavailable.";
        } else {
            die "PDFreactor Web Service error (status: " . $status . ")."
        }
        return 0;
    }
    use constant VERSION => 7;
1;
package PDFreactor::CallbackType;
    use constant {
        FINISH => "FINISH",
        PROGRESS => "PROGRESS",
        START => "START",
    };
package PDFreactor::Cleanup;
    use constant {
        CYBERNEKO => "CYBERNEKO",
        JTIDY => "JTIDY",
        NONE => "NONE",
        TAGSOUP => "TAGSOUP",
    };
package PDFreactor::ColorSpace;
    use constant {
        CMYK => "CMYK",
        RGB => "RGB",
    };
package PDFreactor::Conformance;
    use constant {
        PDF => "PDF",
        PDFA1A => "PDFA1A",
        PDFA1A_PDFUA1 => "PDFA1A_PDFUA1",
        PDFA1B => "PDFA1B",
        PDFA2A => "PDFA2A",
        PDFA2A_PDFUA1 => "PDFA2A_PDFUA1",
        PDFA2B => "PDFA2B",
        PDFA2U => "PDFA2U",
        PDFA3A => "PDFA3A",
        PDFA3A_PDFUA1 => "PDFA3A_PDFUA1",
        PDFA3B => "PDFA3B",
        PDFA3U => "PDFA3U",
        PDFUA1 => "PDFUA1",
        PDFX1A_2001 => "PDFX1A_2001",
        PDFX1A_2003 => "PDFX1A_2003",
        PDFX3_2002 => "PDFX3_2002",
        PDFX3_2003 => "PDFX3_2003",
        PDFX4 => "PDFX4",
        PDFX4P => "PDFX4P",
    };
package PDFreactor::ContentType;
    use constant {
        BINARY => "BINARY",
        BMP => "BMP",
        GIF => "GIF",
        HTML => "HTML",
        JPEG => "JPEG",
        JSON => "JSON",
        NONE => "NONE",
        PDF => "PDF",
        PNG => "PNG",
        TEXT => "TEXT",
        TIFF => "TIFF",
        XML => "XML",
    };
package PDFreactor::CssPropertySupport;
    use constant {
        ALL => "ALL",
        HTML => "HTML",
        HTML_THIRD_PARTY => "HTML_THIRD_PARTY",
        HTML_THIRD_PARTY_LENIENT => "HTML_THIRD_PARTY_LENIENT",
    };
package PDFreactor::Doctype;
    use constant {
        AUTODETECT => "AUTODETECT",
        HTML5 => "HTML5",
        XHTML => "XHTML",
        XML => "XML",
    };
package PDFreactor::Encryption;
    use constant {
        NONE => "NONE",
        TYPE_128 => "TYPE_128",
        TYPE_40 => "TYPE_40",
    };
package PDFreactor::ErrorPolicy;
    use constant {
        LICENSE => "LICENSE",
        MISSING_RESOURCE => "MISSING_RESOURCE",
    };
package PDFreactor::ExceedingContentAgainst;
    use constant {
        NONE => "NONE",
        PAGE_BORDERS => "PAGE_BORDERS",
        PAGE_CONTENT => "PAGE_CONTENT",
        PARENT => "PARENT",
    };
package PDFreactor::ExceedingContentAnalyze;
    use constant {
        CONTENT => "CONTENT",
        CONTENT_AND_BOXES => "CONTENT_AND_BOXES",
        CONTENT_AND_STATIC_BOXES => "CONTENT_AND_STATIC_BOXES",
        NONE => "NONE",
    };
package PDFreactor::HttpsMode;
    use constant {
        LENIENT => "LENIENT",
        STRICT => "STRICT",
    };
package PDFreactor::JavaScriptDebugMode;
    use constant {
        EXCEPTIONS => "EXCEPTIONS",
        FUNCTIONS => "FUNCTIONS",
        LINES => "LINES",
        NONE => "NONE",
        POSITIONS => "POSITIONS",
    };
package PDFreactor::JavaScriptMode;
    use constant {
        DISABLED => "DISABLED",
        ENABLED => "ENABLED",
        ENABLED_NO_LAYOUT => "ENABLED_NO_LAYOUT",
        ENABLED_REAL_TIME => "ENABLED_REAL_TIME",
        ENABLED_TIME_LAPSE => "ENABLED_TIME_LAPSE",
    };
package PDFreactor::KeystoreType;
    use constant {
        JKS => "JKS",
        PKCS12 => "PKCS12",
    };
package PDFreactor::LogLevel;
    use constant {
        DEBUG => "DEBUG",
        FATAL => "FATAL",
        INFO => "INFO",
        NONE => "NONE",
        PERFORMANCE => "PERFORMANCE",
        WARN => "WARN",
    };
package PDFreactor::MediaFeature;
    use constant {
        ASPECT_RATIO => "ASPECT_RATIO",
        COLOR => "COLOR",
        COLOR_INDEX => "COLOR_INDEX",
        DEVICE_ASPECT_RATIO => "DEVICE_ASPECT_RATIO",
        DEVICE_HEIGHT => "DEVICE_HEIGHT",
        DEVICE_WIDTH => "DEVICE_WIDTH",
        GRID => "GRID",
        HEIGHT => "HEIGHT",
        MONOCHROME => "MONOCHROME",
        ORIENTATION => "ORIENTATION",
        RESOLUTION => "RESOLUTION",
        WIDTH => "WIDTH",
    };
package PDFreactor::MergeMode;
    use constant {
        APPEND => "APPEND",
        ARRANGE => "ARRANGE",
        OVERLAY => "OVERLAY",
        OVERLAY_BELOW => "OVERLAY_BELOW",
        PREPEND => "PREPEND",
    };
package PDFreactor::OutputIntentDefaultProfile;
    use constant {
        FOGRA39 => "Coated FOGRA39",
        GRACOL => "Coated GRACoL 2006",
        IFRA => "ISO News print 26% (IFRA)",
        JAPAN => "Japan Color 2001 Coated",
        JAPAN_NEWSPAPER => "Japan Color 2001 Newspaper",
        JAPAN_UNCOATED => "Japan Color 2001 Uncoated",
        JAPAN_WEB => "Japan Web Coated (Ad)",
        SWOP => "US Web Coated (SWOP) v2",
        SWOP_3 => "Web Coated SWOP 2006 Grade 3 Paper",
    };
package PDFreactor::OutputType;
    use constant {
        BMP => "BMP",
        GIF => "GIF",
        JPEG => "JPEG",
        PDF => "PDF",
        PNG => "PNG",
        PNG_AI => "PNG_AI",
        PNG_TRANSPARENT => "PNG_TRANSPARENT",
        PNG_TRANSPARENT_AI => "PNG_TRANSPARENT_AI",
        TIFF_CCITT_1D => "TIFF_CCITT_1D",
        TIFF_CCITT_GROUP_3 => "TIFF_CCITT_GROUP_3",
        TIFF_CCITT_GROUP_4 => "TIFF_CCITT_GROUP_4",
        TIFF_LZW => "TIFF_LZW",
        TIFF_PACKBITS => "TIFF_PACKBITS",
        TIFF_UNCOMPRESSED => "TIFF_UNCOMPRESSED",
    };
package PDFreactor::OverlayRepeat;
    use constant {
        ALL_PAGES => "ALL_PAGES",
        LAST_PAGE => "LAST_PAGE",
        NONE => "NONE",
        TRIM => "TRIM",
    };
package PDFreactor::PageOrder;
    use constant {
        BOOKLET => "BOOKLET",
        BOOKLET_RTL => "BOOKLET_RTL",
        EVEN => "EVEN",
        ODD => "ODD",
        REVERSE => "REVERSE",
    };
package PDFreactor::PagesPerSheetDirection;
    use constant {
        DOWN_LEFT => "DOWN_LEFT",
        DOWN_RIGHT => "DOWN_RIGHT",
        LEFT_DOWN => "LEFT_DOWN",
        LEFT_UP => "LEFT_UP",
        RIGHT_DOWN => "RIGHT_DOWN",
        RIGHT_UP => "RIGHT_UP",
        UP_LEFT => "UP_LEFT",
        UP_RIGHT => "UP_RIGHT",
    };
package PDFreactor::PdfScriptTriggerEvent;
    use constant {
        AFTER_PRINT => "AFTER_PRINT",
        AFTER_SAVE => "AFTER_SAVE",
        BEFORE_PRINT => "BEFORE_PRINT",
        BEFORE_SAVE => "BEFORE_SAVE",
        CLOSE => "CLOSE",
        OPEN => "OPEN",
    };
package PDFreactor::ProcessingPreferences;
    use constant {
        SAVE_MEMORY_IMAGES => "SAVE_MEMORY_IMAGES",
    };
package PDFreactor::QuirksMode;
    use constant {
        DETECT => "DETECT",
        QUIRKS => "QUIRKS",
        STANDARDS => "STANDARDS",
    };
package PDFreactor::ResourceType;
    use constant {
        ATTACHMENT => "ATTACHMENT",
        FONT => "FONT",
        ICC_PROFILE => "ICC_PROFILE",
        IFRAME => "IFRAME",
        IMAGE => "IMAGE",
        MERGE_DOCUMENT => "MERGE_DOCUMENT",
        OBJECT => "OBJECT",
        RUNNING_DOCUMENT => "RUNNING_DOCUMENT",
        SCRIPT => "SCRIPT",
        STYLESHEET => "STYLESHEET",
        UNKNOWN => "UNKNOWN",
    };
package PDFreactor::SigningMode;
    use constant {
        SELF_SIGNED => "SELF_SIGNED",
        VERISIGN_SIGNED => "VERISIGN_SIGNED",
        WINCER_SIGNED => "WINCER_SIGNED",
    };
package PDFreactor::ViewerPreferences;
    use constant {
        CENTER_WINDOW => "CENTER_WINDOW",
        DIRECTION_L2R => "DIRECTION_L2R",
        DIRECTION_R2L => "DIRECTION_R2L",
        DISPLAY_DOC_TITLE => "DISPLAY_DOC_TITLE",
        DUPLEX_FLIP_LONG_EDGE => "DUPLEX_FLIP_LONG_EDGE",
        DUPLEX_FLIP_SHORT_EDGE => "DUPLEX_FLIP_SHORT_EDGE",
        DUPLEX_SIMPLEX => "DUPLEX_SIMPLEX",
        FIT_WINDOW => "FIT_WINDOW",
        HIDE_MENUBAR => "HIDE_MENUBAR",
        HIDE_TOOLBAR => "HIDE_TOOLBAR",
        HIDE_WINDOW_UI => "HIDE_WINDOW_UI",
        NON_FULLSCREEN_PAGE_MODE_USE_NONE => "NON_FULLSCREEN_PAGE_MODE_USE_NONE",
        NON_FULLSCREEN_PAGE_MODE_USE_OC => "NON_FULLSCREEN_PAGE_MODE_USE_OC",
        NON_FULLSCREEN_PAGE_MODE_USE_OUTLINES => "NON_FULLSCREEN_PAGE_MODE_USE_OUTLINES",
        NON_FULLSCREEN_PAGE_MODE_USE_THUMBS => "NON_FULLSCREEN_PAGE_MODE_USE_THUMBS",
        PAGE_LAYOUT_ONE_COLUMN => "PAGE_LAYOUT_ONE_COLUMN",
        PAGE_LAYOUT_SINGLE_PAGE => "PAGE_LAYOUT_SINGLE_PAGE",
        PAGE_LAYOUT_TWO_COLUMN_LEFT => "PAGE_LAYOUT_TWO_COLUMN_LEFT",
        PAGE_LAYOUT_TWO_COLUMN_RIGHT => "PAGE_LAYOUT_TWO_COLUMN_RIGHT",
        PAGE_LAYOUT_TWO_PAGE_LEFT => "PAGE_LAYOUT_TWO_PAGE_LEFT",
        PAGE_LAYOUT_TWO_PAGE_RIGHT => "PAGE_LAYOUT_TWO_PAGE_RIGHT",
        PAGE_MODE_FULLSCREEN => "PAGE_MODE_FULLSCREEN",
        PAGE_MODE_USE_ATTACHMENTS => "PAGE_MODE_USE_ATTACHMENTS",
        PAGE_MODE_USE_NONE => "PAGE_MODE_USE_NONE",
        PAGE_MODE_USE_OC => "PAGE_MODE_USE_OC",
        PAGE_MODE_USE_OUTLINES => "PAGE_MODE_USE_OUTLINES",
        PAGE_MODE_USE_THUMBS => "PAGE_MODE_USE_THUMBS",
        PICKTRAYBYPDFSIZE_FALSE => "PICKTRAYBYPDFSIZE_FALSE",
        PICKTRAYBYPDFSIZE_TRUE => "PICKTRAYBYPDFSIZE_TRUE",
        PRINTSCALING_APPDEFAULT => "PRINTSCALING_APPDEFAULT",
        PRINTSCALING_NONE => "PRINTSCALING_NONE",
    };
package PDFreactor::XmpPriority;
    use constant {
        HIGH => "HIGH",
        LOW => "LOW",
        NONE => "NONE",
    };
